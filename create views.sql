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