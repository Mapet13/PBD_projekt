use pbdproject

drop table if exists Produkty 
create table Produkty
(
	id_produktu int identity,
	nazwa nvarchar(50),
	czy_zawiera_owoce_morza bit,
	id_kategorii int,
	data_dodania datetime

	primary key (id_produktu)
)

drop table if exists Stoliki
create table Stoliki
(
	id_stołu int identity,
	data_dodania datetime,
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
	data_wprowadzenia datetime,
	id_pracownika_wprowadzającego int

	primary key (id_menu)
)

drop table if exists Faktury
create table Faktury
(
	id_faktury int identity,
	id_klienta int,
	data_wystawienia datetime,
	czy_faktura_miesięczna bit,
	id_pracownika_wystawiającego int

	primary key (id_faktury)
)

drop table if exists Produkty_szczegóły
create table Produkty_szczegóły
(
	id_produktu int,
	cena money,
	data_wprowadzenia datetime,
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
	data_wprowadzenia datetime,
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
	data_złorzenia_zamówienia datetime,
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
	data_przyznania datetime

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
	data_dodania datetime,
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
	data_wprowadzenia datetime,
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








-- klucze obce:


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









-- warunki integralnosci:


-- z założenia projektu rezerwacje dla klientów indywidualnych są dostępne od dwóch osób
alter table Rezerwacje_indywidualne add constraint CK_liczba_osób CHECK (liczba_osób >=2)


-- ograniczenia na format adresu email:
alter table Klienci add constraint CK_email CHECK (Klienci.email like '%_@__%.__%')
alter table Pracownicy add constraint CK_email_pracownicy CHECK (email like '%_@__%.__%')


-- wartości procentowe:
alter table Stałe add constraint CK_R1 check (R1>=0 and R1<= 100)
alter table Stałe add constraint CK_R2 check (R2>=0 and R2<= 100)
alter table Przyznane_rabaty_typu_manager add constraint CK_procent CHECK (procent >= 0 AND procent <= 100)

-- ilośc nie moze byc ujemna
alter table Stałe add constraint CK_WZ check (WZ>=0)
alter table Stałe add constraint CK_WK1 check (WK>=0)
alter table Stałe add constraint CK_Z1 check (Z1>=0)
alter table Stałe add constraint CK_K1 check (K1>=0)
alter table Stałe add constraint CK_K2 check (K2>=0)
alter table Stałe add constraint CK_D1 check (D1>=0)
alter table Produkty_szczegóły add constraint CK_cena check (cena > 0)
alter table Stoliki_szczegóły add constraint CK_liczba_miejsc check (liczba_miejsc>0)
alter table Zamówienia_szczegóły add constraint CK_ilość CHECK (Zamówienia_szczegóły.ilość >= 0)


-- nie mozna zmeiniać nic w przeszłości:
alter table Stoliki_szczegóły add constraint CK_data_wprowadzenia check (data_wprowadzenia > current_timestamp)
alter table Stoliki add constraint CK_data_dodania CHECK (data_dodania >= current_timestamp)
alter table Menu add constraint CK_data_wprowadzenia CHECK (data_wprowadzenia >= current_timestamp)
alter table Zamówienia add constraint CK_data_złorzenia_zamówienia check (data_złorzenia_zamówienia >= current_timestamp)
alter table Stałe add constraint CK_Data check (data_wprowadzenia >= current_timestamp)


alter table Pracownicy add constraint CK_data_urodzenia check (  -- sprawdzanie czy sie zgadza z numerem PESEL
    trim(cast(year(data_urodzenia) % 100 as char))+
    trim(cast(month(data_urodzenia) + case
        when 2000<= year(data_urodzenia) and year(data_urodzenia) <=2099 then 20
        when 2100<= year(data_urodzenia) and year(data_urodzenia) <=2199 then 40
        when 2200<= year(data_urodzenia) and year(data_urodzenia) <=2299 then 60
        when 1800<= year(data_urodzenia) and year(data_urodzenia) <=1899 then 80
        when 1900<= year(data_urodzenia) and year(data_urodzenia) <=1999 then 0
        end as char))+
    trim(cast(day(data_urodzenia) as char)) = substring(Pesel,1,6)
    )


-- ograniczenia logiczne na daty:
alter table Zamówienia add constraint CK_data_oczekiwanej_realizacji check (data_oczekiwanej_realizacji >= Zamówienia.data_złorzenia_zamówienia)
alter table Zamówienia add constraint CK_data_Odebrania check (data_odebrania >= Zamówienia.data_złorzenia_zamówienia)
alter table Zamówienia add constraint CK_data_płatności check (data_odebrania >= Zamówienia.data_złorzenia_zamówienia)
alter table Pracownicy add constraint CK_data_zwolnienia check (data_zwolnienia >= Pracownicy.data_zwolnienia)
alter table Pracownicy add constraint CK_data_zatrudnienia check (data_zatrudnienia>=Pracownicy.data_urodzenia)


-- ograniczenia z liczenia sumy konstrolnej numeru NIP:
alter table Klienci_firmowi add constraint CK_NIP check (
    len(NIP)=10 and
    (cast(substring(NIP,1,1) as int) * 6 +
    cast(substring(NIP,2,1) as int) * 5 +
    cast(substring(NIP,3,1) as int) * 7 +
    cast(substring(NIP,4,1) as int) * 2 +
    cast(substring(NIP,5,1) as int) * 3 +
    cast(substring(NIP,6,1) as int) * 4 +
    cast(substring(NIP,7,1) as int) * 5 +
    cast(substring(NIP,8,1) as int) * 6 +
    cast(substring(NIP,9,1) as int) * 7) % 11
        = cast(substring(NIP,10,1) as int)
    )

-- ograniczenia z liczenia sumy konstrolnej numeru PESEL:
alter table Pracownicy add constraint CK_pesel check (
    len(Pesel)=11 and
    (
    (10-(cast(substring(Pesel,1,1) as int) * 1 +
    cast(substring(Pesel,2,1) as int) * 3 +
    cast(substring(Pesel,3,1) as int) * 7 +
    cast(substring(Pesel,4,1) as int) * 9 +
    cast(substring(Pesel,5,1) as int) * 1 +
    cast(substring(Pesel,6,1) as int) * 3 +
    cast(substring(Pesel,7,1) as int) * 7 +
    cast(substring(Pesel,8,1) as int) * 9 +
    cast(substring(Pesel,9,1) as int) * 1 +
    cast(substring(Pesel,10,1) as int) * 3) % 10) % 10
        = cast(substring(Pesel,11,1) as int)
        )
    )
alter table Klienci_indywidualni add constraint CK_pesel_klienci check (
    len(Pesel)=11 and
    (
    (10-(cast(substring(Pesel,1,1) as int) * 1 +
    cast(substring(Pesel,2,1) as int) * 3 +
    cast(substring(Pesel,3,1) as int) * 7 +
    cast(substring(Pesel,4,1) as int) * 9 +
    cast(substring(Pesel,5,1) as int) * 1 +
    cast(substring(Pesel,6,1) as int) * 3 +
    cast(substring(Pesel,7,1) as int) * 7 +
    cast(substring(Pesel,8,1) as int) * 9 +
    cast(substring(Pesel,9,1) as int) * 1 +
    cast(substring(Pesel,10,1) as int


