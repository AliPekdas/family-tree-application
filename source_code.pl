% Family Tree Warehouse Application

:- dynamic person/6.
:- dynamic gender/2.
:- dynamic birth_date/2.
:- dynamic parent/2.
:- dynamic spouse/2.

% Relationship Types
anne(Anne, Child) :- gender(Anne, female), parent(Anne, Child).

baba(Baba, Child) :- gender(Baba, male), parent(Baba, Child).

ogul(Child, Parent) :- gender(Child, male), parent(Parent, Child).

kiz(Child, Parent) :- gender(Child, female), parent(Parent, Child).

erkek_kardes(Bro, Person) :-
    parent(P, Bro), parent(P, Person), Bro \= Person, gender(Bro, male).

kiz_kardes(Sis, Person) :-
    parent(P, Sis), parent(P, Person), Sis \= Person, gender(Sis, female).

abi(Bro, Person) :-
    erkek_kardes(Bro, Person), birth_date(Bro, D1), birth_date(Person, D2), D1 @< D2.

abla(Sis, Person) :-
    kiz_kardes(Sis, Person), birth_date(Sis, D1), birth_date(Person, D2), D1 @< D2.

amca(Amca, Person) :-
    baba(Father, Person), erkek_kardes(Amca, Father).

hala(Hala, Person) :-
    baba(Father, Person), kiz_kardes(Hala, Father).

dayi(Dayi, Person) :-
    anne(Mother, Person), erkek_kardes(Dayi, Mother).

teyze(Teyze, Person) :-
    anne(Mother, Person), kiz_kardes(Teyze, Mother).

yegen(Yegen, Person) :-
    (erkek_kardes(Sibling, Person); kiz_kardes(Sibling, Person)), parent(Sibling, Yegen).

kardes(X, Y) :-
    parent(P, X), parent(P, Y), X \= Y.

kuzen(Kuzen, Person) :-
    parent(P1, Person), parent(P2, Kuzen), kardes(P1, P2).

eniste(Eniste, Person) :-
    kiz_kardes(Sister, Person),
    spouse(Sister, Eniste).

eniste(Eniste, Person) :-
    teyze(Aunt, Person),
    spouse(Aunt, Eniste),
    Eniste \= Person.

eniste(Eniste, Person) :-
    hala(Aunt, Person),
    spouse(Aunt, Eniste),
    Eniste \= Person.

yenge(Yenge, Kisi) :-
    abi(Kisi, Abi),
    spouse(Abi, Yenge).

yenge(Yenge, Kisi) :-
    erkek_kardes(Kisi, Kardes),
    spouse(Kardes, Yenge).

yenge(Yenge, Kisi) :-
    dayi(Kisi, Dayi),
    spouse(Dayi, Yenge).

yenge(Yenge, Kisi) :-
    amca(Kisi, Amca),
    spouse(Amca, Yenge).

kayinvalide(KV, Person) :-
    spouse(Person, Spouse), anne(KV, Spouse).

kayinpeder(KP, Person) :-
    spouse(Person, Spouse), baba(KP, Spouse).

gelin(Gelin, Person) :-
    parent(Person, Child), spouse(Child, Gelin), gender(Gelin, female).

damat(Damat, Person) :-
    parent(Person, Child), spouse(Child, Damat), gender(Damat, male).

bacanak(Bacanak, Person) :-
    spouse(Person, Wife), kiz_kardes(Sister, Wife), spouse(Sister, Bacanak), Bacanak \= Person.

baldiz(Baldiz, Person) :-
    spouse(Person, Husband), kiz_kardes(Baldiz, Husband).

elti(Elti, Person) :-
    spouse(Person, Husband), erkek_kardes(Brother, Husband), spouse(Brother, Elti), Elti \= Person.

kayinbirader(KB, Person) :-
    spouse(Person, Spouse), erkek_kardes(KB, Spouse).

% Helpers

grandparent(GP, Person) :-
    parent(GP, Parent), parent(Parent, Person).

not_realistic_dates(P1, P2) :-
    person(P1, _, B1, D1, _, _),
    person(P2, _, B2, D2, _, _),
    (
        (D1 \= null, number(D1), D1 < B2)
        ;
        (D2 \= null, number(D2), D2 < B1)
    ).

underage_marriage(P1, P2) :-
    get_current_year(CY),
    person(P1, _, B1, D1, _, _),
    person(P2, _, B2, D2, _, _),
    (
        (D1 == null, CY - B1 < 18)
        ;
        (D2 == null, CY - B2 < 18)
    ).

format_atom(Input, Output) :-
    (atom(Input) -> Output = Input ; atom_string(Output, Input)).

get_current_year(2025).

% Main Operations

add_person :-
    write('Please type the father name and surname: '), read(Father),
    write('Please type the mother name and surname: '), read(Mother),
    write('Please type the child person name and surname: '), read(FullName),
    write('Please type the birth date of the child (YYYY): '), read(BirthYear),
    write('Please type the death date of the child (or \'none\'): '), read(DeathRaw),
    write('Please type the child person gender (m/f): '), read(GenderChar),
    format_atom(FullName, Name),
    format_atom(Father, FatherName),
    format_atom(Mother, MotherName),
    (DeathRaw == none -> DeathDate = null ; DeathDate = DeathRaw),
    (GenderChar == f -> Gender = female ; Gender = male),
    assertz(person(Name, Gender, BirthYear, DeathDate, FatherName, MotherName)),
    assertz(gender(Name, Gender)),
    assertz(birth_date(Name, BirthYear)),
    (FatherName \= null -> assertz(parent(FatherName, Name)) ; true),
    (MotherName \= null -> assertz(parent(MotherName, Name)) ; true),
    write('Person added successfully.'), nl.

update_birth(Name, NewBirth) :-
    retract(person(Name, Gender, _, Death, Father, Mother)),
    assertz(person(Name, Gender, NewBirth, Death, Father, Mother)),
    retractall(birth_date(Name, _)),
    assertz(birth_date(Name, NewBirth)).

update_death(Name, DeathRaw) :-
    (DeathRaw == none -> DeathDate = null ; DeathDate = DeathRaw),
    retract(person(Name, Gender, Birth, _, Father, Mother)),
    assertz(person(Name, Gender, Birth, DeathDate, Father, Mother)).

ask_relation :-
    write('Please type first person name and surname: '), read(X),
    write('Please type second person name and surname: '), read(Y),
    format_atom(X, FX), format_atom(Y, FY),
    (   anne(FX, FY) -> write('Anne');
        baba(FX, FY) -> write('Baba');
        ogul(FX, FY) -> write('Oðul');
        kiz(FX, FY) -> write('Kýz');
        abi(FX, FY)  -> write('Abi');
        abla(FX, FY) -> write('Abla');
        erkek_kardes(FX, FY) -> write('Erkek Kardeþ');
        kiz_kardes(FX, FY) -> write('Kýz Kardeþ');
        amca(FX, FY) -> write('Amca');
        hala(FX, FY) -> write('Hala');
        dayi(FX, FY) -> write('Dayý');
        teyze(FX, FY) -> write('Teyze');
        yegen(FX, FY) -> write('Yeðen');
        kuzen(FX, FY) -> write('Kuzen');
        eniste(FX, FY) -> write('Eniþte');
        yenge(FX, FY) -> write('Yenge');
        kayinvalide(FX, FY) -> write('Kayýnvalide');
        kayinpeder(FX, FY) -> write('Kayýnpeder');
        gelin(FX, FY) -> write('Gelin');
        damat(FX, FY) -> write('Damat');
        bacanak(FX, FY) -> write('Bacanak');
        baldiz(FX, FY) -> write('Baldýz');
        elti(FX, FY) -> write('Elti');
        kayinbirader(FX, FY) -> write('Kayýnbirader');
        spouse(FX, FY) -> write('Eþ');  % <- Yeni eklenen satýr
        write('Relationship not found.')
    ), nl.

add_or_update_person :-
    write('1-) Add person'), nl,
    write('2-) Update person'), nl,
    write('Please choose an operation!'), nl,
    read(Choice),
    (Choice = 1 -> add_person; Choice = 2 -> update_person; write('Invalid choice.'), nl).

update_person :-
    write('1. Update the birth year of someone.'), nl,
    write('2. Update the death year of someone.'), nl,
    write('0. Cancel.'), nl,
    write('Enter your choice: '), read(Choice),
    (Choice = 1 -> write('Enter the name: '), read(N), format_atom(N, Name), write('New birth year: '), read(B), update_birth(Name, B);
     Choice = 2 -> write('Enter the name: '), read(N), format_atom(N, Name), write('New death year: '), read(D), update_death(Name, D);
     Choice = 0 -> write('Update cancelled.'), nl;
     write('Invalid choice.'), nl).

get_level(Name, Level) :-
    get_level_rec(Name, 0, Level).

get_level_rec(Name, Acc, Level) :-
    (   parent(P, Name)
    ->  Acc1 is Acc + 1,
        get_level_rec(P, Acc1, Level)
    ;   Level = Acc
    ).

get_person_info :-
    write('Please type the person name and surname: '), read(FullName),
    format_atom(FullName, Name),
    ( person(Name, _, BirthYear, DeathYear, _, _) ->
        get_level(Name, Level),
        findall(C, parent(Name, C), Children),
        length(Children, Count),
        get_current_year(Y),
        (DeathYear == null -> Age is Y - BirthYear, Status = 'Alive'; Age is DeathYear - BirthYear, Status = 'Dead'),
        format('Age: ~w~nLevel: ~w~nChildren: ~w~nStatus: ~w~n', [Age, Level, Count, Status])
    ; write('Person not found.'), nl).

print_family_tree :-
    findall([H, W], (spouse(H, W), H @< W), SpousePairs),
    list_to_set(SpousePairs, UniqueSpouses),
    forall(member([Husband, Wife], UniqueSpouses), (
        print_family_unit(Husband, Wife, 0)
    )),
    findall(P, (person(P, _, _, _, null, null), \+ spouse(P, _)), Roots),
    forall(member(Root, Roots), (
        format('--- LEVEL 0 ---~n~w (Unmarried Root)~n', [Root])
    )).

print_family_unit(Husband, Wife, Level) :-
    Indent is Level * 4,
    tab(Indent), format('--- LEVEL ~w ---~n', [Level]),
    tab(Indent), format('~w - ~w~n', [Husband, Wife]),
    % Çiftin çocuklarýný bul
    findall(C, (parent(Husband, C), parent(Wife, C)), Children),
    NextLevel is Level + 1,
    forall(member(Child, Children), (
        tab(Indent + 4), write(Child), nl,
        print_family_unit_if_married(Child, NextLevel)
    )).

print_family_unit_if_married(Person, Level) :-
    spouse(Person, Spouse),
    Person @< Spouse,
    print_family_unit(Person, Spouse, Level), !.
print_family_unit_if_married(_, _).

add_marriage :-
    write('Name of first person: '), read(A),
    write('Name of second person: '), read(B),
    format_atom(A, P1), format_atom(B, P2),
    (   P1 = P2 -> write('Cannot marry self.'), nl, !, fail;
        \+ person(P1, _, _, _, _, _) -> write('First person is not found.'), nl, !, fail;
        \+ person(P2, _, _, _, _, _) -> write('Second person is not found.'), nl, !, fail;
        invalid_close_relation(P1, P2) -> !, fail;
        not_realistic_dates(P1, P2) -> write('Invalid Marriage: Date conflict.'), nl, !, fail;
        underage_marriage(P1, P2) -> write('Invalid Marriage: Under 18 years old.'), nl, !, fail;
        spouse(P1, _) -> write('First person already married.'), nl, !, fail;
        spouse(P2, _) -> write('Second person already married.'), nl, !, fail;
        assertz(spouse(P1, P2)),
        assertz(spouse(P2, P1)),
        write('Marriage added successfully.'), nl
    ).

invalid_close_relation(P1, P2) :-
    (   anne(P1,P2) -> write('Invalid: Anne - Çocuk'), nl;
        baba(P1,P2) -> write('Invalid: Baba - Çocuk'), nl;
        anne(P2,P1) -> write('Invalid: Anne - Çocuk'), nl;
        baba(P2,P1) -> write('Invalid: Baba - Çocuk'), nl;
        erkek_kardes(P1,P2) -> write('Invalid: Kardeþ'), nl;
        kiz_kardes(P1,P2) -> write('Invalid: Kardeþ'), nl;
        erkek_kardes(P2,P1) -> write('Invalid: Kardeþ'), nl;
        kiz_kardes(P2,P1) -> write('Invalid: Kardeþ'), nl;
        amca(P1,P2) -> write('Invalid: Amca - Yeðen'), nl;
        hala(P1,P2) -> write('Invalid: Hala - Yeðen'), nl;
        dayi(P1,P2) -> write('Invalid: Dayý - Yeðen'), nl;
        teyze(P1,P2) -> write('Invalid: Teyze - Yeðen'), nl;
        amca(P2,P1) -> write('Invalid: Amca - Yeðen'), nl;
        hala(P2,P1) -> write('Invalid: Hala - Yeðen'), nl;
        dayi(P2,P1) -> write('Invalid: Dayý - Yeðen'), nl;
        teyze(P2,P1) -> write('Invalid: Teyze - Yeðen'), nl;
        grandparent(P1,P2) -> write('Invalid: Büyükbaba/Büyükanne - Torun'), nl;
        grandparent(P2,P1) -> write('Invalid: Büyükbaba/Büyükanne - Torun'), nl
    ).

ftwa :-
    repeat,
    nl, write('1-) Ask relation'), nl,
    write('2-) Add/Update person'), nl,
    write('3-) Get information of any person'), nl,
    write('4-) Print the family tree'), nl,
    write('5-) Add marriage'), nl,
    write('6-) Terminate the program'), nl,
    write('Please choose an operation!'), nl,
    read(Choice),
    handle_choice(Choice),
    Choice = 6, !.

handle_choice(1) :- ask_relation.
handle_choice(2) :- add_or_update_person.
handle_choice(3) :- get_person_info.
handle_choice(4) :- print_family_tree.
handle_choice(5) :- add_marriage.
handle_choice(6) :- write('Program terminated.'), nl.
