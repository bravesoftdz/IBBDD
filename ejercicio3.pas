type 
ventas=record;
	cod:integer;
	nombre:string[20];
	monto:real;
	end;
archivo=file of ventas;
procedure compactar(var a:archivo, var nue:archivo);
var
	act:integer;
	aux, venta:ventas;
begin
	reset(a);
	rewrite(nue);
	if (not eof(a)) then read(a, aux);
	while (not eof(a)) do begin
		act:=aux.cod;
		venta.cod:=aux.cod;
		venta.nombre:=aux.nombre;
		venta.monto:=0;
		while ((not eof(a)) and (act=aux.cod)) do begin
			venta.monto:=venta.monto+aux.monto;
			read(a, aux);
			end;
		write(nue, venta);
		end;
	close(a);
	close(nue);
end;

Var
	ar, nuevo:archivo;
Begin
	assign(ar, 'ventas');
	assign(nuevo, 'ventasPorVendedor');
	compactar(ar, nuevo);
End.
