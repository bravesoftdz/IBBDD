type
	fec=record;
	ano:integer;
	mes:integer;
	dia:integer;
	end;
	detalle=record;
	emple:integer;
	fecha:fec;
	hsx:integer;
	end;
	maestro=record;
	emple:integer;
	sede:integer;
	nom:string[20];
	sueldo:real;
	montoph:real;
	end;
	liquidacion=record;
	emple:integer;
	total:real;
	end;
	datos=record;
	emple:integer;
	sede:integer;
	nom:string[20];
	total:real;
	end;
	
det=file of detalle;
mas=file of maestro;
liqui=file of liquidacion;
const
	valoralto=99999;
var
	d1,d2,d3,d4,d5:det;
	m:maestro;
procedure leer(var d:det, var deta:detalle);
begin
	if (not eof(d)) then read(d, deta)
	else deta.emple:=valoralto;
end;
	
procedure minimo(var det, det1, det2, det3, det4, det5:detalle);
begin
	if ((det1.emple<det2.emple) and (det1.emple<det3.emple) and (det1.emple<det4.emple) and (det1.emple<det5.emple)) then begin
		det:=det1;
		leer(d1, det1);
		end
	else if ((det2.emple<det1.emple) and (det2.emple<det3.emple) and (det2.emple<det4.emple) and (det2.emple<det5.emple)) then begin
		det:=det2;
		leer(d2, det2);
		end
	else if ((det3.emple<det1.emple) and (det3.emple<det2.emple) and (det3.emple<det4.emple) and (det3.emple<det5.emple)) then begin
		det:=det3;
		leer(d3, det3);
		end
	else if ((det4.emple<det1.emple) and (det4.emple<det2.emple) and (det4.emple<det3.emple) and (det4.emple<det5.emple)) then begin
		det:=det4;
		leer(d4, det4);
		end
	else begin
		det:=det5;
		leer(d5, det5);
		end;
end;
procedure procesar(var m:mas, var d1,d2,d3,d4,d5:det);
var
	l:liqui;
	dat:datos;
	liq:liquidacion;
	t:Text;
	master:maestro;
	deta1, deta2, deta3, deta4, deta5, deta:detalle;
	hsx:integer;
	tot:real;
begin
	assign(l,'liquidacion-binario')
	assign(t, 'liquidaciones.txt');
	rewrite(l);
	rewrite(t);
	reset(m);
	reset(d1);
	reset(d2);
	reset(d3);
	reset(d4);
	reset(d5);
	leer(d1, deta1);
	leer(d2, deta2);
	leer(d3, deta3);
	leer(d4, deta4);
	leer(d5, deta5);
	minimo(deta,deta1,deta3,deta4,deta5);
	while ((not eof(m)) or deta.cod<>valoralto) do begin
		read(m, master);
		liq.emple:=master.emple;
		dat.emple:=master.emple;
		dat.sede:=master.sede;
		dat.nom:=master.nom;
		hsx:=0;
		while((deta.cod<>valoralto) and (master.emple=deta.emple)) do begin
			hsx:=hsx+deta.hsx;
			minimo(deta,deta1,deta3,deta4,deta5);
			end;
		tot:=hsx*montoph+master.sueldo;
		liq.total:=tot;
		dat.total:=tot;
		write(l, liq);
		write(t, dat);
		end;
	close(l);
	close(t);
	close(m);
	close(d1);
	close(d2);
	close(d3);
	close(d4);
	close(d5);
end;
Begin
	assign(d1,
	assign(d2,
	assign(d3,
	assign(d4,
	assign(d5,	
	assign(m,
	procesar(m,d1,d2,d3,d4,d5);
End.
	
	
	
	