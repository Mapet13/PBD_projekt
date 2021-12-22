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
