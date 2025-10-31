--select *from interno.tipo_persona;
--select *from interno.tipo_persona_rel;

delete from interno.tipo_persona_rel;
delete from interno.tipo_persona;

insert into interno.tipo_persona values ('1','Personal Natural');
insert into interno.tipo_persona values ('2','Persona Juridica');

insert into interno.tipo_persona_rel values ('1','1');
insert into interno.tipo_persona_rel values ('2','2');


