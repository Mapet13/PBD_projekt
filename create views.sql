drop view if exists Aktualne_ceny_produktów;
create view Aktualne_ceny_produktów
as
        with tab as
            (
            select id_produktu, data_wprowadzenia, cena
                from Produkty_szczegóły
            )
        select T1.id_produktu,T1.cena from tab T1
        left outer join tab T2 on T1.data_wprowadzenia<T2.data_wprowadzenia and T1.id_produktu = T2.id_produktu
        where T2.id_produktu is null;

drop view if exists Aktualne_stałe
create view Aktualne_stałe
as
    select T1.* from Stałe T1
        left outer join Stałe T2 on T1.data_wprowadzenia<T2.data_wprowadzenia
        where T2.data_wprowadzenia is null;


drop view if exists Aktualne_menu;
create view Aktualne_menu
as
        with tab as
            (
            select M1.id_menu from Menu M1 left outer join Menu M2 on M1.data_wprowadzenia < M2.data_wprowadzenia
                where M2.id_menu is null
            )
        select Acp.id_produktu,Acp.cena from tab
        join Menu_szczegóły MS on MS.id_menu = tab.id_menu
        join Aktualne_ceny_produktów Acp on MS.id_produktu = Acp.id_produktu;

create view dbo.[Rezerwacje na dzis] as
    select id_rezerwacji,data_rezerwacji
from Rezerwacje
where DAY(data_rezerwacji) = DAY(current_timestamp) and MONTH(data_rezerwacji) = MONTH(current_timestamp) and YEAR(data_rezerwacji) = YEAR(current_timestamp)

create view dbo.[Nierozpatrzone rezerwacje] as
select top 100 Rezerwacje.id_rezerwacji,id_klienta,liczba_osób
from Rezerwacje
    inner join Rezerwacje_indywidualne Ri on Rezerwacje.id_rezerwacji = Ri.id_rezerwacji
WHERE Ri.[Czy rozpatrzona] = 0
order by Rezerwacje.data_rezerwacji

create view dbo.[Niezrealizowanie zamowienia] as
    select top 100 id_zamówienia,data_oczekiwanej_realizacji
from Zamówienia
where Zamówienia.data_odebrania is null
order by data_oczekiwanej_realizacji

-- Wybierz aktualnie zatrudnionych pracowników
create view dbo.Aktialni_pracownicy as
select *
from Pracownicy
WHERE data_zwolnienia IS NULL
  AND data_zatrudnienia <= current_timestamp

create view dbo.Aktualni_managerowie as
select * from Aktualni_pracownicy where czy_manager = 1

-- wybierz aktualnie "działające" stoliki (najnowszy opis i liczba miejsc)
with tab as
         (
             select s.id_stołu, s.liczba_miejsc, s.opis, s.data_wprowadzenia
             from Stoliki_szczegóły as s
			 LEFT OUTER JOIN stoliki on s.id_stołu = stoliki.id_stołu
			 where stoliki.czy_aktualnie_istnieje = 1
         )
select T1.liczba_miejsc, T1.opis
from tab T1
         left outer join tab T2 on T1.data_wprowadzenia < T2.data_wprowadzenia and T1.id_stołu = T2.id_stołu
where T2.id_stołu is null
