CREATE DATABASE aulatriggers01
go
USE aulatriggers01
 
CREATE TABLE servico(
id INT NOT NULL,
nome VARCHAR(100),
preco DECIMAL(7,2)
PRIMARY KEY(ID)
)
 
CREATE TABLE depto(
codigo INT not null,
nome VARCHAR(100),
total_salarios DECIMAL(7,2)
PRIMARY KEY(codigo)
)
 
CREATE TABLE funcionario(
id INT NOT NULL,
nome VARCHAR(100),
salario DECIMAL(7,2),
depto INT NOT NULL
PRIMARY KEY(id)
FOREIGN KEY (depto) REFERENCES depto(codigo))
 
INSERT INTO servico VALUES
(1, 'Orçamento', 20.00),
(2, 'Manutenção preventiva', 85.00)
 
INSERT INTO depto (codigo, nome) VALUES
(1,'RH'),
(2,'DTI')
 
INSERT INTO funcionario VALUES
(1, 'Fulano', 1537.89,2)
INSERT INTO funcionario VALUES
(2, 'Cicrano', 2894.44, 1)
INSERT INTO funcionario VALUES
(3, 'Beltrano', 984.69, 1)
INSERT INTO funcionario VALUES
(4, 'Tirano', 2487.18, 2)

select *from servico
select *from funcionario
select * from depto


--3 TIPOS DE TRIGGERS: AFTER(FOR) , BEFORE*, INSTEAD OF

/*
TRIGGER AFTER
CREATE TRIGGER t_nome on tabela
FOR INSERT,UPDATE,DELETE
AS
	
	PROGRAMAÇÃO

TRIGGER INSTEAD OF 
CREATE TRIGGER t_nome on tabela
INSERT OF INSERT,UPDATE,DELETE
AS
	PROGRAMAÇÃO
*/

/*
	As trigger geram tabelas temporarias chamadas 
	inserted e deleted
*/


CREATE TRIGGER t_viewdepto on depto
for insert, update,delete
as
	begin
		select *from inserted
		select * from deleted
	END
/*
INSERT INTO depto VALUES
(3,'Almoxarifado ',null)

select * from depto


update depto
set nome ='ALM.'
where codigo = 3

delete depto where codigo = 3
*/

CREATE TRIGGER t_protegeservico on servico
FOR DELETE
AS
BEGIN
		ROLLBACK TRANSACTION --desfaz a ultima transação
		RAISERROR ('NÃO É PERMITIDO DELETAR KRL',16,1)
END

DELETE servico WHERE id=1


CREATE TRIGGER t_protegevalorservico on servico
FOR UPDATE
AS
BEGIN
		DECLARE @preconovo AS DECIMAL(7,2),
							@precovelho AS DECIMAL(7,2),
							@idservico AS INT,
							@nomeservico AS VARCHAR(200)

		Select @idservico = id,@nomeservico=nome,@preconovo = preco
					FROM inserted
		Select @precovelho = preco
					FROM deleted
		IF(@precovelho>@preconovo)
		BEGIN	
					ROLLBACK TRANSACTION
					RAISERROR ('O novo valor deve ser >= que o velho valor ',16,2)
		end
END

update servico
set preco = 80.00 where id = 2

select * from servico

--DISABLE TRIGGER 
DISABLE TRIGGER t_protegevalorservico on servico
--ENABLE TRIGGER
ENABLE TRIGGER t_protegevalorservico on servico

CREATE  TRIGGER t_insereservico on servico
INSTEAD OF INSERT 
as 
Begin
	--	ROLLBACK TRANSACTION 
		SELECT *FROM servico
END

insert  INTO servico VALUES 
(10,'XXXX',50)

select *from depto
select * from funcionario
delete funcionario
delete depto

INSERT INTO depto (codigo, nome) VALUES
(1,'RH'),
(2,'DTI')

INSERT INTO funcionario VALUES
(1, 'Fulano', 1537.89,2)
INSERT INTO funcionario VALUES
(2, 'Cicrano', 2894.44, 1)
INSERT INTO funcionario VALUES
(3, 'Beltrano', 984.69, 1)
INSERT INTO funcionario VALUES
(4, 'Tirano', 2487.18, 2)

select * from funcionario

INSERT INTO funcionario VALUES
(1, 'Fulano', 1537.89,2)
INSERT INTO funcionario VALUES
(2, 'Cicrano', 2894.44, 1)
INSERT INTO funcionario VALUES
(3, 'Beltrano', 984.69, 1)
INSERT INTO funcionario VALUES
(4, 'Tirano', 2487.18, 2)

select *from depto
select * from funcionario
delete funcionario where id = 4
delete depto



INSERT INTO depto (codigo, nome) VALUES
(1,'RH'),
(2,'DTI')




create trigger t_Detsalario on funcionario
for insert, update, delete
as
Begin
    Declare
        @id int,
        @depto int,
        @salario decimal(7,2),
        @salarioantigo decimal(7,2),
        @totalsalarios decimal(7,2),
        @aux int
        Set @aux = (select count(*) from deleted)
        if(@aux = 0) /* Se ele entrar aqui é porque inseriu */
        Begin
            select @id = id, @salario = salario, @depto = depto from inserted
            select @totalsalarios = total_salarios from depto where depto.codigo = @depto 
            if(@totalsalarios is null)
            Begin
                Set @totalsalarios = 0
            End
                update depto set total_salarios = @totalsalarios + @salario where depto.codigo = @depto
        End
        else
        Begin
            Select @id = id, @salario = salario, @depto = depto from inserted
            select @salarioantigo = salario from deleted
            if(@salarioantigo > @salario and @salario is not null and @salario != 0)
            Begin
                update depto set total_salarios = total_salarios - (@salarioantigo - @salario) where depto.codigo = @depto
            End
            else
            if(@salarioantigo < @salario and @salario is not null and @salario != 0)
            Begin
                update depto set total_salarios = total_salarios + (@salario - @salarioantigo) where depto.codigo = @depto
            End
            else
            Begin
                select @id = id, @salario = salario, @depto = depto from deleted
                update depto set total_salarios = total_salarios - @salario where depto.codigo = @depto
            End
        End
End