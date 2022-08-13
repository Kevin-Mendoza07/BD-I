use SFCIB
go

create table Clientes(
	Id_Cliente char(5) primary key not null,
	PNC nvarchar(15) not null,
	SNC nvarchar(15),
	PAC nvarchar(15) not null,
	SAC nvarchar(15),
	DirC nvarchar(70) not null,
	Id_Mun int foreign key references Municipios(Id_Mun) not null,
	TelC char(8) check(TelC like '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	EstadoC bit default 1 not null
)
go

alter table Bar add EstadoB bit default 1 not null
go

alter table Empleados add EstadoEmp bit default 1 not null
go

alter table Clientes add Id_Facultad char(3) not null
go

alter table Clientes add constraint fkfc foreign key(Id_Facultad) 
references Facultad(Id_Facultad)

create table Proveedor(
	Id_Prov int identity(1,1) primary key not null,
	NombreProv nvarchar(35) not null,
	DirProv nvarchar(70) not null,
	TelProv char(8) check(TelProv like '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	EstadoProv bit default 1 not null
)

create table Contactos(
	Id_Contacto int identity(1,1) primary key not null,
	PNCont nvarchar(15) not null,
	SNCont nvarchar(15),
	PSCont nvarchar(15) not null,
	SACont nvarchar(15),
	DirCont nvarchar(70) not null,
	Id_Mun int foreign key references Municipios(Id_Mun) not null,
	TelCont char(8) check(TelCont like '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	EstadoCont bit default 1 not null,
	Id_Prov int foreign key references Proveedor(Id_Prov) not null
)

alter table Proveedor add Id_Mun int not null

alter table Proveedor add constraint fkpm foreign key(Id_Mun) references Municipios(Id_Mun)

create table Productos(
	CodProd char(5) primary key not null,
	NombreProd nvarchar(50) not null,
	DescProd nvarchar(50) not null,
	preciop float not null,
	existp int not null,
	EstadoProd bit default 1 not null,
	Id_Prov int foreign key references Proveedor(Id_Prov) not null
)

create rule EPos
as
@v>0

exec sp_bindrule 'EPos','Productos.preciop'
exec sp_bindrule 'EPos','Productos.existp'

create table Ventas(
	Id_Venta int identity(1,1) primary key not null,
	Fecha_Venta datetime default getdate() not null,
	Id_Cliente char(5) foreign key references Clientes(Id_Cliente) not null,
	TotalV float not null
)

create table Det_Ventas(
	Id_Venta int foreign key references Ventas(Id_Venta) not null,
	CodProd char(5) foreign key references Productos(CodProd) not null,
	cantv int not null,
	subtp float,
	primary key(Id_Venta,CodProd)
)

create rule NoNeg
as
@x>=0

exec sp_bindrule 'NoNeg','Ventas.TotalV'
exec sp_bindrule 'EPos','Det_Ventas.cantv'
exec sp_bindrule 'EPos','Det_Ventas.subtp'

create table Pedidos(
	Id_Pedido int identity(1,1) primary key not null,
	FechaPedido datetime default getdate() not null,
	Id_Prov int foreign key references Proveedor(Id_Prov) not null,
	SubtotalP float,
	TotalP float,
	EstadoPedido bit default 1 not null,
)

create table Det_Pedidos(
	Id_Pedido int foreign key references Pedidos(Id_Pedido) not null,
	CodProd char(5) foreign key references Productos(CodProd) not null,
	cantped int not null,
	subtp float,
	preciop float,
	primary key(Id_Pedido,CodProd)
)

exec sp_bindrule 'NoNeg','Pedidos.SubtotalP'
exec sp_bindrule 'NoNeg','Pedidos.TotalP'
exec sp_bindrule 'NoNeg','Det_Pedidos.subtp'
exec sp_bindrule 'EPos','Det_Pedidos.subtp'
exec sp_bindrule 'EPos','Det_Pedidos.preciop'

create table Compras(
	Id_Compras char(5) primary key not null,
	Fecha_Compras datetime not null,
	Id_Pedido int foreign key references Pedidos(Id_Pedido) not null,
	subtotalc float,
	totalc float,
)

create table Det_Compras(
	Id_Compras char(5) foreign key references Compras(Id_Compras) not null,
	CodProd char(5) foreign key references Productos(CodProd) not null,
	cantc int not null,
	precioc float not null,
	subtcom float,
	primary key(Id_Compras,CodProd)
)

exec sp_bindrule 'NoNeg','Compras.subtotalc'
exec sp_bindrule 'NoNeg','Compras.totalc'
exec sp_bindrule 'EPos','Det_Compras.cantc'
exec sp_bindrule 'Epos','Det_Compras.preciop'
exec sp_bindrule 'NoNeg','Det_Compras.subtcom'

--backup database SFCIB to disk 'D:\SFCIB.bak'