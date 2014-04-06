Uses 
	arch, persona;
var
	a:apersonas; p:tpersona; i:integer;
	nom, ape: string [20];
	dni, fecnac: longword;
	exito:boolean;
	exp:text;
begin
	CrearArchivo(a, 'registros');
	for i:= 1 to 3 do begin
		writeln('nombre:');
		read(nom);
		writeln('apellido');
		read(ape);
		writeln('dni');
		read(dni);
		writeln('fech de nacimiento');
		read(fecnac);
		Crear(nom,ape,dni,fecnac,p);
		Insertar(a,p,exito);
		if (exito) then	writeln('La persona se ha argregado exitosamente. ')
		else	writeln('En el archivo ya existÃ­a un registro con el mismo DNI.');
	end;
	Exportar(a, exp, 'exportado.txt');
end.
