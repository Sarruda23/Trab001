CREATE DATABASE trab01
go
use trab01
use master
drop database trab01

create table cliente (
cod_cli int  not null primary key ,
nome varchar(100),
telefone varchar(11),
)

create table produto (
cod_pro int  not null primary key ,
nome varchar(100),
valor_unitario decimal(7,2),
)

create table Venda (
cod_cli int  not null ,
cod_pro int  not null,
data_hora Datetime,
qntd int ,
valor_un decimal(7,2),
valor_total decimal(7,2),
primary key (cod_cli,cod_pro,data_hora),
foreign key (cod_cli) references cliente (cod_cli),
foreign key (cod_pro) references produto (cod_pro)
)

create table evente(
cod_eve int  not null primary key,
valor decimal(7,2) not null,
premio varchar(100) not null
)

select * from produto



create procedure sp_venda(@cod_cli int,@cod_pro int,@qntd int)
as
declare @date_hora datetime,@valor_un decimal(7,2),@valor_total decimal(7,2)
		set @date_hora = getdate()
		set @valor_un = (select valor_unitario from produto where cod_pro = @cod_pro)
		set @valor_total = @valor_un * @qntd
		Insert into Venda values (@cod_cli,@cod_pro,getdate(),@qntd,@valor_un,@valor_total)



Create  FUNCTION fn_Bonus()
returns @tabela table(cod_cli int,nome_cli varchar(100),valor_total decimal(7,2),
					  valor_bonus int,premio varchar(50),restante int)
as
begin
	insert @tabela (cod_cli,nome_cli,valor_total)	SELECT cli.cod_cli,cli.nome, SUM(v.valor_total) 
						from Venda v inner join cliente cli on v.cod_cli=cli.cod_cli group by cli.cod_cli,cli.nome
	UPDATE @tabela set premio = 'nada ' where valor_total <1000 
	UPDATE @tabela set valor_bonus=1000, premio = 'Jogo de Copos ' where valor_total >=1000 and valor_total<2000
	UPDATE @tabela set valor_bonus=2000, premio = 'Jogo de Prato ' where valor_total >= 2000  and valor_total < 3000
    UPDATE @tabela set valor_bonus=3000, premio = 'Jogo de talheres ' where valor_total >= 3000    and valor_total < 4000
	UPDATE @tabela set valor_bonus=4000, premio = 'Jogo de porcelana ' where valor_total >= 4000  and valor_total < 5000
	UPDATE @tabela set valor_bonus=5000, premio = 'Jogo de cristais ' where valor_total >= 5000 
	update @tabela set restante = valor_total - valor_bonus
	return
end
insert into produto values
(1,'Facas','12.5'),
(2,'Tabuas','23.2'),
(3,'panelas','33.33'),
(4,'Fogão','400.44'),
(5,'Geladeira','500.5')

insert into cliente values
(1,'Rafel','11111111111'),
(2,'Tonhão','22222222222'),
(3,'José','33333333333'),
(4,'Zé','44444444444'),
(5,'Manuel','5555555555')

insert into evente values(1,1000,'Jogo de Copos')
insert into evente values(2,2000,'Jogo de Pratos')
insert into evente values(3,3000,'Jogo de Talheres')
insert into evente values(4,4000,'Jogo de Porcelana')
insert into evente values(5,5000,'Jogo de Cristais')

Exec sp_venda 1,1,2
Exec sp_venda 2,2,2
Exec sp_venda 3,3,1
Exec sp_venda 5,5,5

select *from  fn_Bonus()