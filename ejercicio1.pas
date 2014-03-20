Type
	archivo = file of integer;
Var 
	arch:archivo;
	n, e, i, w:integer;
Begin
	assign(arch,'enteros.txt');
	rewrite(arch);
	writeln('Ingrese una cantidad de enteros a generar: ');
	read(n);
    Randomize;
	for i:=1 to n do
	begin
		e:= random(65536) - 32768;
		write(arch, e);
	end;
	close(arch);
End.
