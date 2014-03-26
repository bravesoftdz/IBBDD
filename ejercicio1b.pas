Type
	archivo = File of integer;
procedure menu(var op:integer);
begin
	writeln('Elija una opcion: ');
	writeln('1 - Exportar numeros');
	writeln('2 - Informar positivos y negativos');
	writeln('3 - Informar pares e impares');
	writeln('4 - Informar pares positivos y negativos e impares positivos y negativos');
	writeln('5 - Salir');
	readln(op);
end;
procedure opcion1(var a:archivo);
var
	n, cont:integer;
	nuevo:Text;
begin
	assign(nuevo, 'numeros.txt');
	reset(a);
	rewrite(nuevo);
	while (not eof(a)) do begin
		cont:=0;
		while (not eof(a) and (cont<12)) do begin
			read(a, n);
			if (cont=11) then writeln(nuevo, n:6)
			else write(nuevo, n:6); 
			cont:=cont+1;
			end;
    end;
	close(a);
	close(nuevo);
end;
procedure opcion2(var a:archivo);
var
    num, conta, conta2, pos, neg:integer;
	p, ne:Text;
begin
	assign(p, 'positivos.txt');
	assign(ne, 'negativos.txt');
	reset(a);
	rewrite(p);
	rewrite(ne);
	pos:=0;
	neg:=0;
	conta:=0;
	conta2:=0;
	while (not eof(a)) do begin
		if (conta=12) then conta:=0;
		if (conta2=12) then conta2:=0;
		while (not eof(a) and (conta<12) and (conta2<12)) do begin
			read(a, num);
			if (num>=0) then begin
				pos:=pos+1;
				if (conta=11) then writeln(p, num:6)
				else write(p, num:6);
				conta:=conta+1;
				end
			else begin
				neg:=neg+1;
				if (conta2=11) then writeln(ne, num:6)
				else write(ne, num:6);
				conta2:=conta2+1;
			end;
		end;
	end;
	writeln('Cantidad de numeros positivos: ', pos);
	writeln('Cantidad de numeros negativos: ', neg);
	close(a);
	close(p);
	close(ne);
end;
procedure opcion3(var a:archivo);
var
	n, cont, cont2, par, impar:integer;
	p, imp:Text;
begin
	assign(p, 'pares.txt');
	assign(imp, 'impares.txt');
	reset(a);
	rewrite(p);
	rewrite(imp);
	par:=0;
	impar:=0;
	cont:=0;
	cont2:=0;
	while (not eof(a)) do begin
		if (cont=12) then cont:=0;
		if (cont2=12) then cont2:=0;
		while (not eof(a) and (cont<12) and (cont2<12)) do begin
			read(a, n);
			if (n mod 2=0) then begin
				par:=par+1;
				if (cont=11) then writeln(p, n:6)
				else write(p, n:6); 
				cont:=cont+1;
				end
			else begin
				impar:=impar+1;
				if (cont2=11) then writeln(imp, n:6)
				else write(imp, n:6);
				cont2:=cont2+1;
			end;
		end;
	end;
	writeln('Cantidad de numeros pares: ', par);
	writeln('Cantidad de numeros impares: ', impar);
	close(a);
	close(p);
	close(imp);
end;
procedure opcion4(var a:archivo);
var
	n, cont, cont2, cont3, cont4, par_pos, par_neg, impar_pos, impar_neg:integer;
	pp, pn, ip, ine:Text;
begin
	assign(pp, 'pares_pos.txt');
	assign(pn, 'pares_neg.txt');
	assign(ip, 'nones_pos.txt');
	assign(ine, 'nones_neg.txt');
	reset(a);
	rewrite(pp);
	rewrite(pn);
	rewrite(ip);
	rewrite(ine);
	par_pos:=0;
	impar_pos:=0;
	par_neg:=0;
	impar_neg:=0;
	cont:=0;
	cont2:=0;
	cont3:=0;
	cont4:=0;
	while (not eof(a)) do begin
		if (cont=12) then cont:=0;
		if (cont2=12) then cont2:=0;
		if (cont3=12) then cont3:=0;
		if (cont4=12) then cont4:=0;
		while (not eof(a) and (cont<12) and (cont2<12) and (cont3<12) and (cont4<12)) do begin
			read(a, n);
			if (n mod 2=0) then
              begin
				if (n>=0) then begin
					par_pos:=par_pos+1;
					if (cont=11) then writeln(pp, n:6)
					else write(pp, n:6); 
					cont:=cont+1;
                end
				else begin
					par_neg:=par_neg+1;
					if (cont2=11) then writeln(pn, n:6)
					else write(pn, n:6);
					cont2:=cont2+1;
                end;
		    end
			else
				if (n>=0) then begin
					impar_pos:=impar_pos+1;
					if (cont3=11) then writeln(ip, n:6)
					else write(ip, n:6); 
					cont3:=cont3+1;
					end
				else begin
					impar_neg:=impar_neg+1;
					if (cont4=11) then writeln(ine, n:6)
					else write(ine, n:6);
					cont4:=cont4+1;
                    end;
		end;
	end;
	writeln('Cantidad de numeros pares positivos: ', par_pos);
	writeln('Cantidad de numeros pares negativos: ', par_neg);
	writeln('Cantidad de numeros impares positivos: ', impar_pos);
	writeln('Cantidad de numeros impares negativos: ', impar_neg);
	close(a);
	close(pp);
	close(pn);
	close(ip);
	close(ine);
end;
Var 
	arch:archivo;
	n:integer;
	b:boolean;
Begin
	n:=0;
	b:=true;
	assign(arch,'enteros');
	while (b) do begin
		menu(n);
		case n of
			1: opcion1(arch);
			2: opcion2(arch);
			3: opcion3(arch);
			4: opcion4(arch);
			5: b:=false;
            end;
end;
End.
