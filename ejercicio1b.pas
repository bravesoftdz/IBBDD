Type
	archivo = file of integer;
procedure menu(var op:integer);
begin
	writeln('Elija una opción: ');
	writeln('1 - Exportar números');
	writeln('2 - Informar positivos y negativos');
	writeln('3 - Informar pares e impares');
	writeln('4 - Informar pares positivos y negativos e impares positivos y negativos');
	writeln('5 - Salir');
	readln(op);
end;
procedure opcion1(var a:archivo, var nuevo:Text);
var
	n, cont:integer;
begin
	reset(a);
	rewrite(nuevo);
	while (not eof(a)) do begin
		cont:=0;
		while (not eof(a) and cont<=12) do begin
			read(a, n);
			if (cont=12) then writeln(nuevo, n:6)
			else write(nuevo, n:6); 
			cont:=cont+1;
			end;
	close(a);
	close(nuevo);
end;
procedure opcion2(var a:archivo, var p:Text, var ne:Text);
var
	n, cont, cont2, pos, neg:integer;
begin
	reset(a);
	rewrite(p);
	rewrite(ne);
	pos:=0;
	neg:=0;
	cont:=0;
	cont2:=0;
	while (not eof(a)) do begin
		if (cont=12) then cont:=0;
		if (cont2=12) then cont2:=0;
		while (not eof(a) and cont<12 and cont2<12) do begin
			read(a, n);
			if (n>=0) then begin
				pos:=pos+1;
				if (cont=11) then writeln(p, n:6)
				else write(p, n:6); 
				cont:=cont+1;
				end
			else begin
				neg:=neg+1;
				if (cont2=11) then writeln(ne, n:6)
				else write(ne, n:6);
				cont2:=cont2+1;
			end;
		end;
	end;
	writeln('Cantidad de números positivos: ', pos);
	writeln('Cantidad de números negativos: ', neg);
	close(a);
	close(p);
	close(ne);
end;
procedure opcion3(var a:archivo, var p:Text, var imp:Text);
var
	n, cont, cont2, par, impar:integer;
begin
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
		while (not eof(a) and cont<12 and cont2<12) do begin
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
	writeln('Cantidad de números pares: ', par);
	writeln('Cantidad de números impares: ', impar);
	close(a);
	close(p);
	close(imp);
end;
procedure opcion3(var a:archivo, var pp:Text, var pn:Text, var ip:Text, var in:Text);
var
	n, cont, cont2, cont3, cont4, par_pos, par_neg, impar_pos, impar_neg:integer;
begin
	reset(a);
	rewrite(pp);
	rewrite(pn);
	rewrite(ip);
	rewrite(in);
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
		while (not eof(a) and cont<12 and cont2<12 and cont3<12 and cont4<12) do begin
			read(a, n);
			if (n mod 2=0) then begin
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
				end
			else begin
				if (n>=0) then begin
					impar_pos:=impar_pos+1;
					if (cont3=11) then writeln(ip, n:6)
					else write(ip, n:6); 
					cont3:=cont3+1;
					end
				else begin
					impar_neg:=impar_neg+1;
					if (cont4=11) then writeln(in, n:6)
					else write(in, n:6);
					cont4:=cont4+1;
		end;
	end;
	writeln('Cantidad de números pares positivos: ', par_pos);
	writeln('Cantidad de números pares negativos: ', par_neg);
	writeln('Cantidad de números impares positivos: ', impar_pos);
	writeln('Cantidad de números impares negativos: ', impar_neg);
	close(a);
	close(pp);
	close(pn);
	close(ip);
	close(in);
end;
Var 
	arch:archivo;
	nue, pos, neg, par, impar, par_pos, par_neg, impar_pos, impar_neg:Text;
	n:integer;
	b:boolean;
Begin
	n:=0;
	b:=true;
	assign(arch,'enteros.txt');
	assign(nue, 'numeros.txt');
	assign(pos, 'positivos.txt');
	assign(neg, 'negativos.txt');
	assign(par, 'pares.txt');
	assign(impar, 'nones.txt');
	assign(par_pos, 'pares_pos.txt');
	assign(par_neg, 'pares_neg.txt');
	assign(impar_pos, 'nones_pos.txt');
	assign(impar_neg, 'nones_neg.txt');
	reset(arch);
	while (b) do begin
		menu(n);
		case n of
			1: opcion1(arch, nue);
			2: opcion2(arch, pos, neg);
			3: opcion3(arch, par, impar);
			4: opcion4(arch, par_pos, par_neg, impar_pos, impar_neg);
			5: b:=false;
End.