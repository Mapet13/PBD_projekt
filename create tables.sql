use pbdproject

drop table if exists Produkty 
create table Produkty
(
	id_produktu int identity,
	nazwa nvarchar(50),
	czy_zawiera_owoce_morza bit,
	id_kategorii int,
	data_dodania datetime default current_timestamp

	primary key (id_produktu)
)

drop table if exists Stoliki
create table Stoliki
(
	id_stołu int identity,
	data_dodania datetime default current_timestamp,
	czy_aktualnie_istnieje bit

	primary key (id_stołu)
)

drop table if exists Rezerwacje
create table Rezerwacje 
(
	id_rezerwacji int identity,
	id_klienta int,
	data_rezerwacji datetime
	
	primary key (id_rezerwacji)
)

drop table if exists Rezerwacje_indywidualne
create table Rezerwacje_indywidualne
(
	id_rezerwacji int,
	data_akceptacji datetime,
	id_zamówienia int,
	liczba_osób int,
	id_pracownika_zatwierdzającego int

	primary key (id_rezerwacji)
)

drop table if exists Menu
create table Menu
(
	id_menu int identity,
	data_wprowadzenia datetime default current_timestamp,
	id_pracownika_wprowadzającego int

	primary key (id_menu)
)

drop table if exists Faktury
create table Faktury
(
	id_faktury int identity,
	id_klienta int,
	data_wystawienia datetime default current_timestamp,
	czy_faktura_miesięczna bit,
	id_pracownika_wystawiającego int

	primary key (id_faktury)
)

drop table if exists Produkty_szczegóły
create table Produkty_szczegóły
(
	id_produktu int,
	cena money,
	data_wprowadzenia datetime default current_timestamp,
	id_pracownika_dodającego int

	primary key (id_produktu,data_wprowadzenia)
)

drop table if exists Kategorie_produktów
create table Kategorie_produktów
(
	id_kategorii int identity,
	nazwa nvarchar(50)

	primary key (id_kategorii)
)

drop table if exists Stoliki_szczegóły
create table Stoliki_szczegóły
(
	id_stołu int,
	liczba_miejsc int,
	data_wprowadzenia datetime default current_timestamp,
	id_pracownika_dodającego int,
	opis text

	primary key (id_stołu,data_wprowadzenia)
)

drop table if exists Rezerwacje_stolików
create table Rezerwacje_stolików
(
	id_stołu int,
	id_rezerwacji int

	primary key (id_stołu,id_rezerwacji)
)

drop table if exists Rezerwacje_osoby
create table Rezerwacje_osoby
(
	id_rezerwacji int,
	id_klienta int

	primary key (id_rezerwacji,id_klienta)
)

drop table if exists Menu_szczegóły
create table Menu_szczegóły
(
	id_menu int,
	id_produktu int

	primary key (id_menu,id_produktu)
)

drop table if exists Faktura_szczegóły
create table Faktura_szczegóły
(
	id_faktury int,
	id_zamówienia int

	primary key(id_zamówienia,id_faktury)
)

drop table if exists Powiązania_KI_KF
create table Powiązania_KI_KF
(
	id_klienta_indywidualnego int,
	id_klienta_firmowego int

	primary key (id_klienta_indywidualnego,id_klienta_firmowego)
)

drop table if exists Klienci_firmowi
create table Klienci_firmowi
(
	NIP varchar(10),
	id_klienta int,
	nazwa_firmy nvarchar(200)

	primary key (id_klienta)
)

drop table if exists Pracownicy
create table Pracownicy
(
	id_pracownika int identity,
	Imie nvarchar(50),
	Nazwisko nvarchar(50),
	Pesel char(11),
	data_zatrudnienia date,
	data_urodzenia date,
	data_zwolnienia date null,
	adres_zamieszkania nvarchar(200),
	uzytkownik sysname,
	czy_manager bit,
	email nvarchar(100)

	primary key (id_pracownika)
)

drop table if exists Zamówienia
create table Zamówienia
(
	id_zamówienia int identity,
	data_złorzenia_zamówienia datetime default current_timestamp,
	czy_na_wynos bit,
	id_rabatu int null,
	data_oczekiwanej_realizacji datetime,
	data_odebrania datetime null,
	id_klienta int,
	data_płatności datetime null,
	czy_przez_internet bit

	primary key (id_zamówienia)
)

drop table if exists Przyznane_rabaty
create table Przyznane_rabaty
(
	id_rabatu int identity,
	id_klienta int,
	data_przyznania datetime default current_timestamp

	primary key (id_rabatu)
)

drop table if exists Przyznane_rabaty_typu_2
create table Przyznane_rabaty_typu_2
(
	id_rabatu int,
	data_wykorzystania datetime null

	primary key (id_rabatu)
)

drop table if exists Klienci_indywidualni
create table Klienci_indywidualni
(
	imię nvarchar(50),
	nazwisko nvarchar(50),
	pesel char(11),
	id_klienta int

	primary key (id_klienta)
)

drop table if exists Klienci
create table Klienci
(
	id_klienta int identity,
	data_dodania datetime default current_timestamp,
	email nvarchar(200),
	adres nvarchar(200)

	primary key (id_klienta)
)

drop table if exists Stałe
create table Stałe
(
	WZ money,
	WK int,
	Z1 int,
	K1 money,
	R1 float,
	K2 money,
	R2 float,
	D1 int,
	data_wprowadzenia datetime default current_timestamp,
	id_pracownika_wprowadzającego int

	primary key (data_wprowadzenia)
)

drop table if exists Zamówienia_szegóły
create table Zamówienia_szczegóły
(
	id_zamówienia int,
	id_produktu int,
	ilość int

	primary key (id_zamówienia,id_produktu)
)

drop table if exists Pracujący_nad_zamówieniem
create table Pracujący_nad_zamówieniem
(
	id_zamówienia int,
	id_pracownika int

	primary key (id_zamówienia,id_pracownika)
)

drop table if exists Przyznane_rabaty_typu_manager
create table Przyznane_rabaty_typu_manager
(
	id_rabatu int,
	procent float,
	id_pracownika int

	primary key (id_rabatu)
)



drop table if exists Przyznane_rabaty_typu_1
create table Przyznane_rabaty_typu_1
(
	id_rabatu int
	primary key (id_rabatu)
)





-- klucze obce:

alter table Przyznane_rabaty_typu_1 add foreign key (id_rabatu) references Przyznane_rabaty(id_rabatu)


alter table Przyznane_rabaty_typu_manager add foreign key (id_rabatu) references Przyznane_rabaty(id_rabatu)
alter table Przyznane_rabaty_typu_manager add foreign key (id_pracownika) references Pracownicy(id_pracownika)

alter table Pracujący_nad_zamówieniem add foreign key (id_pracownika) references Pracownicy(id_pracownika)
alter table Pracujący_nad_zamówieniem add foreign key (id_zamówienia) references Zamówienia(id_zamówienia)


alter table Zamówienia_szczegóły add foreign key (id_zamówienia) references Zamówienia(id_zamówienia)
alter table Zamówienia_szczegóły add foreign key (id_produktu) references Produkty(id_produktu)

alter table Stałe add foreign key (id_pracownika_wprowadzającego) references Pracownicy(id_pracownika)

alter table Klienci_indywidualni add foreign key (id_klienta) references Klienci(id_klienta)

alter table Przyznane_rabaty_typu_2 add foreign key (id_rabatu) references Przyznane_rabaty(id_rabatu)

alter table Przyznane_rabaty add foreign key (id_klienta) references Klienci(id_klienta)


alter table Zamówienia add foreign key (id_klienta) references Klienci(id_klienta)
alter table Zamówienia add foreign key (id_rabatu) references Przyznane_rabaty(id_rabatu)

alter table Klienci_firmowi add foreign key (id_klienta) references Klienci(id_klienta)
alter table Powiązania_KI_KF add foreign key (id_klienta_indywidualnego) references Klienci_indywidualni(id_klienta)
alter table Powiązania_KI_KF add foreign key (id_klienta_firmowego) references Klienci_firmowi(id_klienta)

alter table Faktura_szczegóły add foreign key (id_faktury) references Faktury(id_faktury)
alter table Faktura_szczegóły add foreign key (id_zamówienia) references Zamówienia(id_zamówienia)


alter table Menu_szczegóły add foreign key (id_menu) references Menu(id_menu)
alter table Menu_szczegóły add foreign key (id_produktu) references Produkty(id_produktu)

alter table Rezerwacje_osoby add foreign key (id_rezerwacji) references Rezerwacje(id_rezerwacji)
alter table Rezerwacje_osoby add foreign key (id_klienta) references Klienci(id_klienta)

alter table Rezerwacje_stolików add foreign key (id_stołu) references Stoliki(id_stołu)
alter table Rezerwacje_stolików add foreign key (id_rezerwacji) references Rezerwacje(id_rezerwacji)

alter table Stoliki_szczegóły add foreign key (id_stołu) references Stoliki(id_stołu)
alter table Stoliki_szczegóły add foreign key (id_pracownika_dodającego) references Pracownicy(id_pracownika)

alter table Produkty_szczegóły add foreign key (id_produktu) references Produkty(id_produktu)
alter table Produkty_szczegóły add foreign key (id_pracownika_dodającego) references Pracownicy(id_pracownika)

alter table Faktury add foreign key (id_klienta) references Klienci(id_klienta)
alter table Faktury add foreign key (id_pracownika_wystawiającego) references Pracownicy(id_pracownika)

alter table Menu add foreign key (id_pracownika_wprowadzającego) references Pracownicy(id_pracownika)

alter table Rezerwacje_indywidualne add foreign key (id_rezerwacji) references Rezerwacje(id_rezerwacji)
alter table Rezerwacje_indywidualne add foreign key (id_zamówienia) references Zamówienia(id_zamówienia)
alter table Rezerwacje_indywidualne add foreign key (id_pracownika_zatwierdzającego) references Pracownicy(id_pracownika)

alter table Rezerwacje add foreign key (id_klienta) references Klienci(id_klienta)

alter table Produkty add foreign key (id_kategorii) references Kategorie_produktów(id_kategorii)


alter table Rezerwacje_indywidualne	add [Czy rozpatrzona] bit default 0