drop view if exists Aktualne_ceny_produktów;
create view Aktualne_ceny_produktów --dla każdego produktu wyświetla jego aktualną cenę
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
create view Aktualne_stałe -- wyświetla aktualne wartości stałych
as
    select T1.* from Stałe T1
        left outer join Stałe T2 on T1.data_wprowadzenia<T2.data_wprowadzenia
        where T2.data_wprowadzenia is null;



drop view if exists Aktualne_menu;
create view Aktualne_menu -- wyświetla aktualne menu (id_produktu i jego cena)
as
        with tab as
            (
            select M1.id_menu from Menu M1 left outer join Menu M2 on M1.data_wprowadzenia < M2.data_wprowadzenia
                where M2.id_menu is null
            )
        select Acp.id_produktu,Acp.cena from tab
        join Menu_szczegóły MS on MS.id_menu = tab.id_menu
        join Aktualne_ceny_produktów Acp on MS.id_produktu = Acp.id_produktu;



drop view if exists dbo.[Rezerwacje na dzis] 
create view dbo.[Rezerwacje na dzis] as -- wyświetla rezerwacje na dzisiaj
    select id_rezerwacji,data_rezerwacji
from Rezerwacje
where DAY(data_rezerwacji) = DAY(current_timestamp) and MONTH(data_rezerwacji) = MONTH(current_timestamp) and YEAR(data_rezerwacji) = YEAR(current_timestamp)



drop view if exists dbo.[Nierozpatrzone rezerwacje]
create view dbo.[Nierozpatrzone rezerwacje] as -- wyświetla rezerwacje do rozpatrzenia
select top 100 percent Rezerwacje.id_rezerwacji,id_klienta,liczba_osób
from Rezerwacje
    inner join Rezerwacje_indywidualne Ri on Rezerwacje.id_rezerwacji = Ri.id_rezerwacji
WHERE Ri.[Czy rozpatrzona] = 0
order by Rezerwacje.data_rezerwacji



drop view if exists dbo.[Niezrealizowanie zamowienia]
create view dbo.[Niezrealizowanie zamowienia] as -- wyświetla zamówienia do zrealizowania
    select top 100 percent id_zamówienia,data_oczekiwanej_realizacji
from Zamówienia
where Zamówienia.data_odebrania is null
order by data_oczekiwanej_realizacji



-- Wybierz aktualnie zatrudnionych pracowników
drop view if exists dbo.Aktialni_pracownicy
create view dbo.Aktialni_pracownicy as
select *
from Pracownicy
WHERE data_zwolnienia IS NULL
  AND data_zatrudnienia <= current_timestamp



drop view if exists dbo.Aktualni_managerowie
create view dbo.Aktualni_managerowie as
select * from Aktualni_pracownicy where czy_manager = 1



-- wybierz aktualnie "działające" stoliki (najnowszy opis i liczba miejsc)
drop view if exists dbo.Aktualne_stoliki
create view dbo.Aktualne_stoliki as
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



-- pokaz wszystkie produkty bedace owocami z informacja czy jest aktualnie w menu
drop view if exists Produkty_z_owocami_morza
create view Produkty_z_owocami_morza as
select P.id_produktu, IIF(AM.id_produktu is not null,'tak','nie') as 'Czy jest aktualnie w menu'  from Produkty P
left outer join Aktualne_menu Am on P.id_produktu = Am.id_produktu
where P.czy_zawiera_owoce_morza = 1



-- ilości produktów na niezrealizowanych zamówieniach z owocami morza
drop view if exists ilości_produktów_z_owocami_morza_do_zamówienia
create view ilości_produktów_z_owocami_morza_do_zamówienia as
    select P.id_produktu,sum(Zs.ilość) as ilość ,min(Z.data_oczekiwanej_realizacji) as 'najpóźniej do' from Produkty P
    join Zamówienia_szczegóły Zs on P.id_produktu = Zs.id_produktu
    join Zamówienia Z on Zs.id_zamówienia = Z.id_zamówienia
    join [Niezrealizowanie zamowienia] [N z] on Z.id_zamówienia = [N z].id_zamówienia
    where P.czy_zawiera_owoce_morza = 1
    group by P.id_produktu



--funkcja pomocnicza do poniższego widoku
drop function if exists id_menu_kiedy_dodano_do_menu_dla_produktu
create function id_menu_kiedy_dodano_do_menu_dla_produktu (@prod_id int)
RETURNS int
as begin
    Declare @out int
    select top 1 @out = M.id_menu
    from Menu_szczegóły MS
             join Menu M on MS.id_menu = M.id_menu
             left join (
        select M2.id_menu, M2.data_wprowadzenia
        from Menu M2
        except
        select M2.id_menu, M2.data_wprowadzenia
        from Menu M2
                 join Menu_szczegóły MS2 on M2.id_menu = MS2.id_menu
        where MS2.id_produktu = @prod_id
    )
        as M3 on M3.data_wprowadzenia > M.data_wprowadzenia
    where MS.id_produktu = @prod_id
      and M3.id_menu is null
    order by M.data_wprowadzenia asc
    return @out
end

--widok pokazujący produkty aktualnie znajdujące się w menu, wraz z datami dodania do niego 
drop view if exists Aktualne_menu_z_datami_wprowadzenia_produktów
create view Aktualne_menu_z_datami_wprowadzenia_produktów as
select top 100 percent AM.id_produktu, M.data_wprowadzenia
    from Aktualne_menu AM
    join Menu M on id_menu = dbo.id_menu_kiedy_dodano_do_menu_dla_produktu(AM.id_produktu)
    order by M.data_wprowadzenia asc
