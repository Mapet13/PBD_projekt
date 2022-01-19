create procedure Wystaw_fakture_miesieczną(@id_klienta int , @month date,@id_pracownika int)
as
begin
    declare @id_faktury int
    declare @zamówienia table(id_zamówienia int)
    insert into @zamówienia select Zamówienia.id_zamówienia from Zamówienia
        left outer join Faktura_szczegóły Fs on Zamówienia.id_zamówienia = Fs.id_zamówienia
        where YEAR(@month) = YEAR(data_złorzenia_zamówienia)
          and Month(@month) = MONTH(data_złorzenia_zamówienia)
          and id_faktury is null
    if (select count(id_zamówienia) from @zamówienia) = 0
        return
    insert into Faktury values (@id_klienta,current_timestamp,1,@id_pracownika)
    select @id_faktury=SCOPE_IDENTITY()
    insert into Faktura_szczegóły
        select @id_faktury,id_zamówienia from @zamówienia
end


create procedure Wystaw_fakture(@id_klienta int ,@id_zamówienia int,@id_pracownika int)
as
begin
    declare @id_faktury int
    if @id_zamówienia in (select id_zamówienia from Faktura_szczegóły)
        raiserror('zamówienie jest już na jakiejś fakturze',5,0)
    insert into Faktury values (@id_klienta,current_timestamp,1,@id_pracownika)
    select @id_faktury=SCOPE_IDENTITY()
    insert into Faktura_szczegóły values (@id_faktury,@id_zamówienia)
end

CREATE procedure dodaj_stolik(
    @liczba_miejsc INT, @opis text, @id_pracownika INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Stoliki (data_dodania, czy_aktualnie_istnieje)
    VALUES (CURRENT_TIMESTAMP, 1);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Stoliki_szczegóły (id_stołu, liczba_miejsc, data_wprowadzenia, id_pracownika_dodającego, opis)
    VALUES (@id, @liczba_miejsc, CURRENT_TIMESTAMP, @id_pracownika, @opis);
end

CREATE procedure dodaj_produkt(
    @nazwa nvarchar(50), @czy_zawiera_produkt_morza bit, @id_kategorii int, @cena int, @id_pracownika int
)
AS
begin
    DECLARE @product_id INT;

    INSERT INTO Produkty (nazwa, czy_zawiera_owoce_morza, id_kategorii, data_dodania)
    VALUES (@nazwa, @czy_zawiera_produkt_morza, @id_kategorii, CURRENT_TIMESTAMP);

    SET @product_id = SCOPE_IDENTITY();

    INSERT INTO Produkty_szczegóły (id_produktu, cena, data_wprowadzenia, id_pracownika_dodającego)
    VALUES (@product_id, @cena, CURRENT_TIMESTAMP, @id_pracownika);
end


create procedure Dodaj_klienta_firmowego(@email nvarchar(200), @adres nvarchar(200),@NIP varchar(10),@nazwa_firmy nvarchar(200))
as
    begin
        declare @id_klienta int
        insert into Klienci (data_dodania, email, adres) values (current_timestamp,@email,@adres)
        set @id_klienta = scope_identity()
        insert into Klienci_firmowi (NIP, id_klienta, nazwa_firmy) values (@NIP,@id_klienta,@nazwa_firmy)
    end


create procedure Dodaj_klienta_indywidualnego(@email nvarchar(200), @adres nvarchar(200),@imie nvarchar(50), @nazwisko nvarchar(50), @pesel char(11))
as
    begin
        declare @id_klienta int
        insert into Klienci (data_dodania, email, adres) values (current_timestamp,@email,@adres)
        set @id_klienta = scope_identity()
        insert into Klienci_indywidualni (imię, nazwisko, pesel, id_klienta) values (@imie,@nazwisko,@pesel,@id_klienta)
    end
CREATE procedure dodaj_rabat_typu_manager(
@id_klienta INT , @procent INT, @id_pracownika INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Przyznane_rabaty (id_klienta, data_przyznania)
    VALUES (@id_klienta, CURRENT_TIMESTAMP);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Przyznane_rabaty_typu_manager (id_rabatu, procent, id_pracownika)
    VALUES (@id, @procent, @id_pracownika);
end

CREATE procedure dodaj_rabat_typu_1(
@id_klienta INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Przyznane_rabaty (id_klienta, data_przyznania)
    VALUES (@id_klienta, CURRENT_TIMESTAMP);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Przyznane_rabaty_typu_1 (id_rabatu)
    VALUES (@id);
end

CREATE procedure dodaj_rabat_typu_2(
@id_klienta INT
)
AS
begin
    DECLARE @id INT;

    INSERT INTO Przyznane_rabaty (id_klienta, data_przyznania)
    VALUES (@id_klienta, CURRENT_TIMESTAMP);

    SET @id = SCOPE_IDENTITY();

    INSERT INTO Przyznane_rabaty_typu_2 (id_rabatu)
    VALUES (@id);
end

create procedure Dodaj_rezerwacje_indywidualną(@id_zamówienia int, @liczba_osób int)
as begin
    declare @id_klienta int
    declare @kiedy_zamówiono datetime
    declare @WK int
    declare @WZ money
    declare @data_realizacji datetime
    declare @WZs varchar(50)
    declare @godzina_otwarcia time
    declare @godzina_zamknięcia time
    select @kiedy_zamówiono=data_złorzenia_zamówienia,@data_realizacji=data_oczekiwanej_realizacji from Zamówienia where id_zamówienia=@id_zamówienia
    select @Wk = WK,@WZ = WZ, @godzina_otwarcia = godzina_otwarcia, @godzina_zamknięcia = godzina_zamknięcia from dbo.Stałe_w_danym_momencie_w_czasie(@kiedy_zamówiono)
    Set @WZs = convert(varchar(50),@WZ,0)
    select @id_klienta=id_klienta from Zamówienia where id_zamówienia=@id_zamówienia
    if (select count(id_zamówienia) from Zamówienia where id_klienta = @id_klienta and data_złorzenia_zamówienia < @kiedy_zamówiono) < @WK
        raiserror('by złorzyć rezerwacje trzeba mieć wcześniej złożonych conajmniej %d zamówień',5,0,@WK)
    if dbo.Wartość_zamówienia(@id_zamówienia)<@WZ
        raiserror('rezerwacje można złorzyć wyłącznie do zamówienia za minimum %s zł',5,1,@WZs)
    if @data_realizacji < current_timestamp
        raiserror('nie można złorzyć rezerwacji na zamówienie które już mineło',5,1)
    if @godzina_otwarcia is not null and  cast(@data_realizacji as time) < @godzina_otwarcia
        raiserror('nie można złorzyć rezerwacji na zamówienie przed otwarciem restauracji',5,1)
    if @godzina_zamknięcia is not null and  cast(@data_realizacji as time) > @godzina_zamknięcia
        raiserror('nie można złorzyć rezerwacji na zamówienie po zamknięciu restauracji',5,1)
    insert into Rezerwacje values (@id_klienta,@data_realizacji)
    declare @id_rezerwacji int
    set @id_rezerwacji = SCOPE_IDENTITY()
    insert into Rezerwacje_indywidualne values (@id_rezerwacji,null,@id_zamówienia,@liczba_osób,null,0)
end








create type tabela_produktów_na_zamówieniu as table
    (
        id_produktu int,
        ilość int check (ilość>0)
    )
create procedure złóż_zamówienie
(
    @tabela_produkty tabela_produktów_na_zamówieniu readonly,
    @id_klienta int,
    @czy_na_wynos bit,
    @czy_przez_internet bit,
	@id_rabatu int=null,
	@data_oczekiwanej_realizacji datetime = null,
	@data_płatności datetime= null,
	@id_zamówienia int output,
	@wartość_zamówienia money output
)
as begin
    if @data_oczekiwanej_realizacji is null
        set @data_oczekiwanej_realizacji = current_timestamp
    declare @godzina_otwarcia time
    declare @godzina_zamknięcia time
    select @godzina_zamknięcia = godzina_zamknięcia, @godzina_otwarcia = godzina_otwarcia from Aktualne_stałe;
    if @id_klienta not in (select id_klienta from Klienci)
        raiserror('nie ma takiego klienta',5,1)
    if  @id_rabatu is not null and  @id_rabatu in (select  id_rabatu from Zamówienia)
        raiserror('zabat został już wykorzystany',5,2)
    if @id_rabatu in (select id_rabatu from Przyznane_rabaty_typu_2)
        begin
            declare @D1 int
            declare @data_przyznania datetime
            select @data_przyznania=data_przyznania from Przyznane_rabaty where id_rabatu = @id_rabatu
            select @D1 = D1 from Stałe_w_danym_momencie_w_czasie(@data_przyznania);
            if dateadd(day,@D1,@data_przyznania) < current_timestamp
                raiserror('zabat się przeterminował',5,2)
           end
    if @godzina_otwarcia is not null and  cast(@data_oczekiwanej_realizacji as time) < @godzina_otwarcia
        raiserror('nie można złorzyć zamówienia na przed otwarciem restauracji',5,3)
    if @godzina_zamknięcia is not null and  cast(@data_oczekiwanej_realizacji as time) > @godzina_zamknięcia
        raiserror('nie można złorzyć zamówienia na po zamknięciu restauracji',5,3)
    if @data_oczekiwanej_realizacji< current_timestamp
        raiserror('nie można złożyć rezerwacji na czas przed teraz',5,3)
    if (select MAX(convert(tinyint,czy_zawiera_owoce_morza)) from Produkty P join @tabela_produkty TP on P.id_produktu= TP.id_produktu) = 1
        begin
            if (datepart(dw,@data_oczekiwanej_realizacji) not in (5,6,7))
                raiserror('zamówienia z owocami moża można zamawiać tylko na czwartek, piątek lub sobotę',5,4)
            declare @first_tuesday datetime
            set @first_tuesday = dateadd(day,3 - datepart(dw,@data_oczekiwanej_realizacji),cast(@data_oczekiwanej_realizacji as date))
            if (@data_oczekiwanej_realizacji >= @first_tuesday)
                raiserror('zamówienia z owocami moża można zamawiać tylko do poniedziałku poprzedzającego zamówienie',5,4)
        end

    insert into Zamówienia values (current_timestamp,@czy_na_wynos,@id_rabatu,@data_oczekiwanej_realizacji,null,@id_klienta,@data_płatności,@czy_przez_internet)
    set @id_zamówienia = scope_identity()
    insert into Zamówienia_szczegóły select @id_zamówienia,id_produktu,ilość from @tabela_produkty

    set @wartość_zamówienia = dbo.Wartość_zamówienia(@id_zamówienia)
end


create type tabela_produktów_w_menu as table
    (
        id_produktu int
    )

create procedure dodaj_menu(
    @tabela_produkty tabela_produktów_w_menu readonly ,
    @data_początkowa datetime,
    @id_pracownika int
)as begin
    if(@id_pracownika not in (select id_pracownika from Pracownicy))
        raiserror('nie ma takiego pracownika',5,0)
    if(@data_początkowa < dateadd(d,1,current_timestamp))
        raiserror('menu może być ustalane co najmniej z jednodniowym wyprzedzeniem',5,0)
    declare @data_od_kiedy_patrzymy datetime
    set @data_od_kiedy_patrzymy = dateadd(d,-(select dni_do_zmiany_menu from Aktualne_stałe) ,current_timestamp)
    declare @maksymalna_procent_niezmienionych_produktów float
    declare @maksymalna_procent_niezmienionych_produktów_napis varchar(max)
    set @maksymalna_procent_niezmienionych_produktów = (100-(select minimalna_ilośc_rotowanych_produktów from Aktualne_stałe))
    set @maksymalna_procent_niezmienionych_produktów_napis = convert(VARCHAR,@maksymalna_procent_niezmienionych_produktów)
    declare @ilość_niezmienianych_produktów int
    select  @ilość_niezmienianych_produktów =  count(id_produktu) from @tabela_produkty TP join Menu M on M.id_menu = dbo.id_menu_kiedy_dodano_do_menu_dla_produktu(TP.id_produktu) where data_wprowadzenia < @data_od_kiedy_patrzymy
    if @ilość_niezmienianych_produktów > @maksymalna_procent_niezmienionych_produktów/ 100 * (select count(id_produktu) from @tabela_produkty)
        raiserror('co najmniej %s%% produktów musi zostać zmienionych',5,1,@maksymalna_procent_niezmienionych_produktów_napis)
    declare @id_menu int
    insert into Menu values (@data_początkowa,@id_pracownika)
    set @id_menu = scope_identity()
    insert into Menu_szczegóły select @id_menu,id_produktu from @tabela_produkty;

end