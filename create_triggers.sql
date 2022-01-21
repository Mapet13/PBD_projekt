
--triggery pełnią rolę check-ów międzytabelowych


create trigger Tr_rezerwacje_indywidualne_data_akceptacji on Rezerwacje_indywidualne
    before INSERT ,UPDATE
    AS
    begin
        select i.id_rezerwacji from inserted i join Rezerwacje R on i.id_zamówienia = R.id_rezerwacji
            where i.data_akceptacji < R.data_dodania
        if @@ROWCOUNT > 0
            raiserror('data akceptacji nie może być wcześniejsza niż data złorzenia rezerwacji',5,1)
    end



create trigger Tr_rezerwacje_indywidualne_pracownik_akceptujący on Rezerwacje_indywidualne
    before INSERT ,UPDATE
    AS
    begin
        select i.id_rezerwacji from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika_zatwierdzającego
            where AP.id_pracownika is null
        if @@ROWCOUNT > 0
            raiserror('rezerwacje mogą zatwierdzać tylko aktualnie pracujący pracownicy',5,2)
    end

create trigger Tr_Menu on Menu
    before INSERT ,UPDATE
    AS
    begin
        select i.id_menu from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika_wprowadzającego
            where AP.id_pracownika is null or AP.czy_manager = 0
        if @@ROWCOUNT > 0
            raiserror('menu mogą zatwierdzać tylko aktualnie pracujący managerzy',5,1)
    end

create trigger Tr_Faktury on Faktury
    after INSERT ,UPDATE
    AS
    begin
        select i.id_faktury from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika_wystawiającego
            where AP.id_pracownika is null or AP.czy_manager = 0
        if @@ROWCOUNT > 0
            raiserror('faktury mogą wystawiać tylko aktualnie pracujący managerzy',5,1)
    end



create trigger Tr_Produkty_szczegóły on Produkty_szczegóły
    after INSERT ,UPDATE
    AS
    begin
        select i.id_produktu from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika_dodającego
            where AP.id_pracownika is null or AP.czy_manager = 0
        if @@ROWCOUNT > 0
            raiserror('ceny produktów mogą zmieniać tylko aktualnie pracujący managerzy',5,1)
    end


create trigger Tr_Stoliki_szczegóły on Stoliki_szczegóły
    after INSERT ,UPDATE
    AS
    begin
        select i.id_stołu from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika_dodającego
            where AP.id_pracownika is null or AP.czy_manager = 0
        if @@ROWCOUNT > 0
            raiserror('dane stolika mogą zmieniać tylko aktualnie pracujący managerzy',5,1)
    end


create trigger Tr_Rezerwacje_osoby on Rezerwacje_osoby
    after INSERT ,UPDATE
    AS
    begin
        select i.id_klienta from inserted i left outer join Klienci_indywidualni KI on KI.id_klienta = i.id_klienta
            where KI.id_klienta is null
        if @@ROWCOUNT > 0
            raiserror('klient reprezentujący osobę podany w rezerwacji nie może nie być klientem indywidualnym',5,1)
    end


create trigger Tr_Stałe on Stałe
    after INSERT ,UPDATE
    AS
    begin
        select i.data_wprowadzenia from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika_wprowadzającego
            where AP.id_pracownika is null or AP.czy_manager = 0
        if @@ROWCOUNT > 0
            raiserror('Stałe mogą zmieniać tylko aktualnie pracujący managerzy',5,1)
    end



create trigger Tr_Przyznane_rabaty_typu_manager on Przyznane_rabaty_typu_manager
    after INSERT ,UPDATE
    AS
    begin
        select i.id_rabatu from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika
            where AP.id_pracownika is null or AP.czy_manager = 0
        if @@ROWCOUNT > 0
            raiserror('Rabaty typu manager mogą przyznawać tylko aktualnie pracujący managerzy',5,1)
    end


create trigger Tr_Pracujący_nad_zamówieniem on Pracujący_nad_zamówieniem
    after INSERT ,UPDATE
    AS
    begin
        select i.id_pracownika from inserted i left outer join Aktialni_pracownicy AP on AP.id_pracownika = i.id_pracownika
            where AP.id_pracownika is null
        if @@ROWCOUNT > 0
            raiserror('Nad zamówieniem mogą pracować tylko aktualnie pracujący pracownicy',5,1)
    end