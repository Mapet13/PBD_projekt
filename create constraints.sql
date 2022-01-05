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


alter table Pracownicy add constraint CK_data_urodzenia check ( -- sprawdzanie czy sie zgadza z numerem PESEL
    RIGHT('00'+CAST(year(data_urodzenia) % 100 AS VARCHAR(2)),2)+
       RIGHT('00'+CAST(month(data_urodzenia) + case
        when 2000<= year(data_urodzenia) and year(data_urodzenia) <=2099 then 20
        when 2100<= year(data_urodzenia) and year(data_urodzenia) <=2199 then 40
        when 2200<= year(data_urodzenia) and year(data_urodzenia) <=2299 then 60
        when 1800<= year(data_urodzenia) and year(data_urodzenia) <=1899 then 80
        when 1900<= year(data_urodzenia) and year(data_urodzenia) <=1999 then 0
        end AS VARCHAR(2)),2)+
       RIGHT('00'+CAST(day(data_urodzenia) % 100 AS VARCHAR(2)),2) = substring(Pesel,1,6)
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


