--select *from interno.tipo_deudor
--select *from interno.tipo_deudor_rel

delete from interno.tipo_deudor_rel;
delete from interno.tipo_deudor;

insert into interno.tipo_deudor values ('1','Deudor directo');
insert into interno.tipo_deudor values ('2','Deudor indirecto');

insert into interno.tipo_deudor_rel values ('1','1');
insert into interno.tipo_deudor_rel values ('2','2');
