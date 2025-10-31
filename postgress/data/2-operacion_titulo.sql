--select *from interno.operacion_titulo
--select *from interno.operacion_titulo_rel

delete from interno.operacion_titulo_rel;
delete from interno.operacion_titulo;

insert into interno.operacion_titulo values ('1','Si, deuda positiva');
insert into interno.operacion_titulo values ('2','Si, deuda negativa');
insert into interno.operacion_titulo values ('3','Si, deuda positiva y negativa');
insert into interno.operacion_titulo values ('4','No');

insert into interno.operacion_titulo_rel values ('1','1');
insert into interno.operacion_titulo_rel values ('2','2');
insert into interno.operacion_titulo_rel values ('3','3');
insert into interno.operacion_titulo_rel values ('4','4');

