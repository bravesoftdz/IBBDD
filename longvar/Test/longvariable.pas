UNIT longvariable;
INTERFACE
		 Uses sysutils;
         Const
              LongBloque = 1024;
              FIN_REGISTRO = '@';
              FIN_CAMPO = '#';
              FIN_BLOQUE = '*';
         Type
             tNroBloque = Word;
             tBloque = Array[1..LongBloque] of Byte;
             abPersonas = File;
             tEstado = (C, E, LE);
             tPersona = Record
                      DNI: Longword;
                      Apellido: String[20];
                      Nombres: String[20];
                      FechaNac: Longword;
             end;
             ctlPersonas = Record
                         estado: tEstado;
                         arch: abPersonas;
                         b: tBloque;
                         ib: Word;
                         libres: File of Word;
                         libre: Word;
                         pe: Array[1..60] of Byte;
                         lpe: Word;
                         p: tPersona;
             end;

			 Procedure Consultar_nombre(var nom:String; P:tpersona);                 //pone en nom el nombre del registro P;
			 Procedure Consultar_apellido(var ape:String; P:tpersona);               //pone en ape el apellido del registro P;
			 Function Consultar_dni(P:tpersona):Longword;                                //devuelve el dni del registro P;
			 Function Consultar_fecha(P:tpersona):Longword;
			 
             Procedure CrearArchivo(var a: ctlPersonas; nom:String; nomlib:String);
             Procedure Abrir(var a: ctlPersonas; nom:String; nomlib:String; modo: tEstado);
             Procedure Cerrar(var a: ctlPersonas);
             Procedure Cargar(var a:ctlPersonas);
             Procedure DevolverPersona (var a:ctlPersonas; var p:tpersona);
             Procedure Insertar (var a:ctlPersonas; var exito:boolean);
             Procedure Exportar(var a:ctlPersonas; var nue:Text; nom:String);
             Procedure Eliminar(var a:ctlPersonas; dni:Longword; var exito:boolean);
             Procedure Recuperar(var a:ctlPersonas; dni:Longword; var exito:boolean);
             Procedure Modificar(var a:ctlPersonas; nom:String; ape:String; dni:Longword; fecha:Longword; var exito:boolean);
             Procedure Primero (var a:ctlPersonas; var exito:boolean);
             Procedure Siguiente (var a:ctlPersonas; var exito:boolean);
             Procedure Respaldar (var A:ctlPersonas; nombre:String);
             
             Procedure ImprimirBloque(var a:ctlPersonas);

IMPLEMENTATION

              Procedure CrearArchivo(var a: ctlPersonas; nom:String; nomlib:String);
              begin
				   Assign(a.arch, nom);
				   Assign(a.libres, nomlib);
                   Rewrite(a.arch, LongBloque);
                   Rewrite(a.libres);
                   a.estado:=E;
                   a.ib:=1;
              end;
 
              Procedure Abrir(var a: ctlPersonas; nom:String; nomlib:String; modo: tEstado);
              begin
					Assign(a.arch, nom);
					Assign(a.libres, nomlib);
                   Reset(a.arch, LongBloque); Reset(a.libres);
                   a.estado:=modo;
                   if (modo=E) then
                   begin
                        Seek(a.arch, FileSize(a.arch)-1);
                        BlockRead(a.arch, a.b, 1);
                        Seek(a.libres, FileSize(a.libres)-1);
                        Read(a.libres, a.libre);
                        a.ib:=LongBloque - a.libre+1;
                   end
                   else if (modo=LE) then a.ib:=1;
              end;
 
              Procedure Cerrar(var a: ctlPersonas);
              begin
                   Close(a.arch);
                   Close(a.libres);
                   a.Estado:=C;
              end;

			procedure Consultar_nombre(var nom:String; P:tPersona);
			begin
				nom:=P.Nombres;
			end;
			procedure Consultar_apellido(var ape:String; P:tPersona);
			begin
				ape:= P.Apellido;
			end;
			function Consultar_dni(P:tPersona):Longword;
			begin
				Consultar_dni:= P.DNI;
			end;
			function Consultar_fecha(P:tPersona):Longword;
			begin
				Consultar_fecha:= P.FechaNac;
			end;

              Function UltimoBloqueLibre(a:ctlPersonas):boolean;
              begin
                   Seek(a.libres, (FileSize(a.libres)-1));
                   Read(a.libres, a.libre);
                   Seek(a.libres,0);
                   UltimoBloqueLibre:= (a.libre>=a.lpe);
              end;

              Procedure DevolverPersona (var a:ctlPersonas; var p:tpersona);
              Begin
				p:= a.p;
			end;

              Procedure Empaquetar (var a:ctlPersonas);
              var
                 sx: String;
                 i: integer;
              begin
                   i:=1;
                   Str(a.p.dni, sx);
                   sx:=sx+FIN_CAMPO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   sx:=a.p.Apellido+FIN_CAMPO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   sx:=a.p.Nombres+FIN_CAMPO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   Str(a.p.FechaNac, sx);
                   sx:=sx+FIN_REGISTRO;
                   Move(sx[1], a.pe[i], Length(sx));
                   Inc(i, Length(sx));
                   a.lpe:= i;
                   //a.ib := a.ib + i; Borrar ya que no sirve
              end;

              Procedure EscribirEnBloqueUltimo(var a:ctlPersonas);    // devuelve en a.b el bloque listo para ser escrito
              var
                 i, act: word;
              begin
                   i:= 1;
                   act:= 1;
                   while (a.b[i] <> Ord(FIN_BLOQUE)) do            i:= i+1;	// aca tendria que copiar tambien las marcas
                   while (a.pe[act] <> Ord(FIN_REGISTRO)) do
                   begin
                        Move(a.pe[act], a.b[i], 1); // mueve el caracter de a.pe[act] a a.b[i] (un solo caracter)
                        i:= i+1;
                        act:= act+1;
                   end;
                   a.b[i]:=Ord(FIN_REGISTRO);
                   a.b[i+1]:=Ord(FIN_BLOQUE);
                   Seek(a.libres,(FileSize(a.arch)-1));
                   read(a.libres,a.libre);
                   a.libre:= a.libre - a.lpe;
                   Seek(a.libres,(FilePos(a.libres)-1));
                   write(a.libres,a.libre);
              end;

              Procedure EscribirEnBloqueNuevo(var a:ctlPersonas);
              var
				i:word;
              begin
                   i:= 1;
                   while(a.pe[i] <> Ord(FIN_REGISTRO)) do     //aca conviene que despues del while se ponga la marca FIN_BLOQUE
                   begin
                        Move(a.pe[i], a.b[i], 1);
                        i:= i+1;
                   end;
                   a.b[i]:=Ord(FIN_REGISTRO);
                   a.b[i+1]:=Ord(FIN_BLOQUE);
                   Seek(a.libres, FileSize(a.libres));
                   a.libre:= longbloque-a.lpe-1;
                   write(a.libres,a.libre);
              end;
              
				Procedure Exportar(var a:ctlPersonas; var nue:Text; nom:String);
				Var
					i:word;
					output, sx:String;
				Begin
					assign(nue, nom);
					Rewrite(nue);
					Seek(a.arch, 0);
					while (not EoF(a.arch)) do begin
						BlockRead(a.arch, a.b, 1);
						a.ib:=1;
						i:=a.ib;
						while(a.b[a.ib] <> Ord(FIN_BLOQUE)) do begin
							while(a.b[a.ib] <> Ord(FIN_CAMPO)) do 
								a.ib:=a.ib+1;
							Move (a.b[i] , sx[1] , a.ib - i);
							Val (sx , a.p.DNI);
							output:= 'DNI: ' + IntToStr(a.p.DNI) + ' ';
							a.ib := a.ib +1;
							i := a.ib;
							while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
								a.ib := a.ib + 1;
							a.p.Apellido:=Chr(a.ib-i);
							Move (a.b[i] , a.p.Apellido[1], a.ib - i);
							output:=output + 'Apellido: ' + a.p.Apellido + ' ';
							a.ib := a.ib + 1;
							i := a.ib;
							while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
								a.ib := a.ib + 1;
							a.p.Nombres:=Chr(a.ib-i);
							Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
							output:= output + 'Nombres: ' + a.p.Nombres + ' ';
							a.ib := a.ib + 1;
							i := a.ib;
							while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do
								a.ib := a.ib + 1;
							Move (a.b[i] , sx[1] , a.ib - i);
							Val (sx , a.p.FechaNac);
							output := output + 'Fecha de Nacimiento: ' + IntToStr(a.p.FechaNac) + '.';
							writeln(nue, output);
							a.ib := a.ib+1;
							i := a.ib;
						end;
					end;
				End;
              
              //Ramiro
              Procedure Eliminar(var a:ctlPersonas; dni:Longword; var exito:boolean);
              var
				sx:String;
				b:boolean;
				i, act:word;
              begin
				b:=false;
				Str(dni, sx);
				while ((not EOF(a.arch)) and (not b)) do begin					// recorre el archivo buscando el bloque que contiene 'dni'
					BlockRead(a.arch, a.b, 1);
					a.ib:=1;
					while ((a.b[a.ib] <> Ord(FIN_BLOQUE)) and (not b)) do begin			// recorre el bloque buscando un dni igual
						i:=1;
						while ((a.b[a.ib] <> Ord(FIN_CAMPO)) and (a.b[a.ib] = Ord(sx[i]))) do begin   // realiza la comparacion
							i:=i+1;
							a.ib:=a.ib+1;
						end;
						if (a.b[a.ib] = Ord(FIN_CAMPO)) then b:=true
						else begin
							while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do a.ib:=a.ib+1;			// si no lo encuentra se ubica en el registro siguiente
							a.ib:=a.ib+1;
						end;
					end;
				end;
				if (b) then begin
					act:=a.ib;					// 'act' es el indice de las posiciones a reacomodar
					a.ib:=a.ib-Length(sx)-1;		// 'a.ib' es el indice de la posicion donde empieza el registro a eliminar
					repeat act:=act+1; until (a.b[act] = Ord(FIN_REGISTRO));
					act:=act+1;
					{
					* seek(a.libres, FilePos(a.arch)-1);
					* read(a.libres, a.libre);
					* t := LongBloque - a.libre - act;    // calcula la cantidad de bytes para hacer el corrimiento
					* Move(a.b[act], a.b[a.ib], t);
					* } 
					Move (a.b[act], a.b[a.ib], LongBloque-act+1);			// se realiza el corrimiento solapando el registro a borrar
					act:=act-a.ib;
					BlockWrite(a.arch, a.b, 1);					// se escribe la modificacion en el archivo
					seek(a.libres, FilePos(a.arch)-1);
					read(a.libres, a.libre);
					a.libre:=a.libre+act;		// 'act' se utiliza para calcular la cantidad de bytes libres
					seek(a.libres, FilePos(a.libres)-1);
					write(a.libres, a.libre);				// se actualiza el archivo de libres
				end;
				exito := b;
              end;


			Procedure Recuperar(var a:ctlPersonas; dni:Longword; var exito:boolean);
              var
				sx:String;
				b:boolean;
				i, t, checkpointer:word;
              begin
				b:=false;
				Str(dni, sx);
				Seek(a.arch, 0);
				while ((not EoF(a.arch)) and (not b)) do begin					// recorre el archivo buscando el bloque que contiene 'dni'
					BlockRead(a.arch, a.b, 1);
					a.ib:=1;
					while ((a.b[a.ib] <> Ord(FIN_BLOQUE)) and (not b)) do begin			// recorre el bloque buscando un dni igual
						i:=1;
						writeln('a.ib:= ', a.ib, '  i:= ', i);//
						writeln('a.b[a.ib]:= ', a.b[a.ib], '  sx[i]:= ', Ord(sx[i]));//
						while ((a.b[a.ib] <> Ord(FIN_CAMPO)) and (a.b[a.ib] = Ord(sx[i]))) do begin   // realiza la comparacion
							writeln('a.ib:= ', a.ib, '  i:= ', i);//
							writeln('a.b[a.ib]:= ', Chr(a.b[a.ib]), '  sx[i]:= ', sx[i]);//
							i:=i+1;
							a.ib:=a.ib+1;
						end;
						if (a.b[a.ib] = Ord(FIN_CAMPO)) then b:=true
						else begin
							while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do a.ib:=a.ib+1;			// si no lo encuentra se ubica en el registro siguiente
							a.ib:=a.ib+1;
						end;
					end;
				end;
				checkpointer:= a.ib;
				if (b) then begin
					a.p.DNI:=dni;
					a.ib:=a.ib+1;
					i := a.ib;
					t:=0;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					a.p.Apellido[0]:=Chr(t);
					Move(a.b[i], a.p.Apellido[1], t);
					a.ib:=a.ib+1;
					i:=a.ib;
					t:=0;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					a.p.Nombres[0]:=Chr(t);
					Move(a.b[i], a.p.Nombres[1], t);
					a.ib:=a.ib+1;
					i:=a.ib;
					t:=0;
					while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], sx[1], t);
					Val(sx, a.p.FechaNac);
					a.ib:= checkpointer;
				end;
				exito:=b;
              end;
			
			//Franco
			Procedure CrearPersona(var P:tPersona; nom:String; ape:String; dnis:Longword; fecha:Longword);
			begin
				with P do
				begin
					Nombres:= nom;
					Apellido:= ape;
					DNI:= dnis;
					FechaNac:=fecha;
				end;
			end;
			
			procedure CargarPersona(var A:ctlPersonas);
			var
				nombre, apellido: String;
				dni, fecha: Longword;
			begin
				write('Escriba su nombre: ');
				readln(nombre);
				write('Escriba su apellido: ');
				readln(apellido);
				write('Escriba su dni: ');
				readln(dni);
				write('Escriba su fecha de nacimiento (AAAAMMDD): ');
				readln(fecha);
				writeln();
				CrearPersona(A.p, nombre, apellido, dni, fecha);
			end;
			
			Procedure Insertar (var a:ctlPersonas; var exito:boolean);
			var
				fin: boolean;
			Begin
				Seek(a.libres,0);
				CargarPersona(a);
				Empaquetar(a);
				fin:= false;
				while ((not fin) and (not EoF(a.libres))) do
				begin
					read(a.libres, a.libre);
					if (a.libre >= a.lpe) then
					begin
						fin:= true;
						Seek(a.libres,(FilePos(a.libres)-1));
					end;
				end;
				if (fin) then
				begin
					Seek(a.arch, FilePos(a.libres));
					BlockRead(a.arch, a.b, 1);
					Move(a.pe[1], a.b[LongBloque-a.libre], a.lpe);
					a.b[LongBloque-a.libre+a.lpe]:=Ord(FIN_BLOQUE); //LongBloque-act+a.lpe+1??
					a.libre:= a.libre-a.lpe;
					write(a.libres,a.libre);
				end
				else	Cargar(a);
				exito:= true;
				End;
			
			  Procedure Cargar(var a:ctlPersonas);
              begin
                   if (a.estado <> LE) then    a.estado:= LE;
				   if (FileSize(a.arch)=0) then 
				   begin
						CargarPersona(a);
						Empaquetar(a);
						Move(a.pe[1], a.b[1], a.lpe);
						a.b[a.lpe+1]:=Ord(FIN_BLOQUE);
						BlockWrite(a.arch, a.b, 1);
						Seek(a.libres, 0);
						a.libre:= LongBloque-a.lpe-1;
						write(a.libres, a.libre);
					end
					else
					begin
						Seek(a.arch, (FileSize(a.arch)-1));
						BlockRead(a.arch, a.b, 1);
						CargarPersona(a);
						Empaquetar(a);
						if (UltimoBloqueLibre(a)) then
						begin
							Seek(a.arch, (FilePos(a.arch)-1)); //vuelve al ultimo bloque a seguir escribiendo
							EscribirEnBloqueUltimo(a);
						end
						else EscribirEnBloqueNuevo(a);
						BlockWrite(a.arch, a.b, 1);
					end;
			end;
			
			Procedure Modificar(var a:ctlPersonas; nom:String; ape:String; dni:Longword; fecha:Longword; var exito:boolean);
			var
				i, tamanio, aux:Word;
				c:Longword;
			begin
				Recuperar(a, dni, exito);
				if (exito) then // si no se encontro la persona a modificar exito=false
				begin		
					Empaquetar(a);
					tamanio:= a.lpe;   //tamaño en bytes del original
					CrearPersona(a.p, nom, ape, dni, fecha);
					Empaquetar(a);
					//a.ib:=a.ib-SizeOf(dni);
					while((a.ib>0) and (a.b[a.ib] <> Ord(FIN_REGISTRO))) do a.ib:=a.ib-1;
					a.ib:=a.ib+1;
					if(a.lpe<=tamanio) then 
					begin
						Move(a.pe[1],a.b[a.ib],a.lpe); 
						if(a.lpe<tamanio) then //si es igual no se debe hacer ningun corrimiento en el bloque
						begin
							i:=a.ib+a.lpe; //i se pone desde el ultimo lugar copiado, es decir desde 
							while(a.b[i]<> Ord(FIN_BLOQUE)) do
							begin
								a.b[i]:= a.b[i+tamanio-a.lpe];
								i:= i+1;
							end;
						end;
						Seek(a.arch, (FilePos(a.arch)-1)); // posiciona a.arch en el lugar a rescribir el bloque
						BlockWrite(a.arch, a.b, 1); 
						Seek(a.libres, FilePos(a.arch)-1); // posiciona el archivo libres en la posicion del bloque actual para modificar el espacio libre
						read(a.libres, a.libre);
						Seek(a.libres, (FilePos(a.libres)-1));
						write(a.libres, (a.libre+(tamanio-a.lpe)));
					end
					else // si es mayor el corrimiento debe ser al reves
					begin
						//controlar que no se exceda el tamaño del bloque
						Seek(a.libres, FilePos(a.arch)-1);
						read(a.libres,a.libre);
						if(a.libre >= (tamanio-a.lpe)) then //entra en el bloque
						begin
							//hacer el corrimiento
							c:=a.lpe-tamanio+1; // c es cantidad de espacio que hay q hacer el corrimiento
							aux:=a.ib+tamanio;  //se para al comienzo del siguiente registro
							i:= aux;
							while(a.b[i]<> Ord(FIN_BLOQUE)) do
								i:=i+1;
							while(i >= aux) do
							begin
								a.b[i+c]:=a.b[i];
								i:=i-1;
							end;
							Move(a.pe[1],a.b[a.ib],a.lpe); 
							Seek(a.arch, (FilePos(a.arch)-1)); // posiciona a.arch en el lugar a rescribir el bloque
							BlockWrite(a.arch, a.b, 1);
							Seek(a.libres, (FilePos(a.arch)-1)); // posiciona el archivo libres en la posicion del bloque actual para modificar el espacio libre (-1 ya que con el blockwrite paso a la siguiente posicion)
							read(a.libres, a.libre);
							Seek(a.libres, (FilePos(a.libres)-1));
							write(a.libres, (a.libre+(a.lpe-tamanio))); //como a.lpe-tamanio<0 en realidad pasa de ser una suma a ser una resta (suma de numero negativo)
						end
						else //no entra en el bloque por lo tanto hay que correr en otro u otros bloques
							exito:=false;
					end;
				end;
			end;
			
			// Leandro
			Procedure Primero (var a : ctlPersonas ; var exito : boolean);
			var
				i : word;
				sx : string;
			begin
				a.estado := LE;
				Seek (a.arch,0);
				a.ib:=1;
				if (not eof(a.arch)) then begin
					BlockRead(a.arch,a.b,1);
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.DNI);
					a.ib := a.ib +1;
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Apellido[1], a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.FechaNac);
					exito := true;
				end
				else exito := false;
			end;
				
			Procedure Siguiente (var a : ctlPersonas ; var exito : boolean);
			var
				i : word;
				sx : string;
			begin
				while(a.b[a.ib] <> Ord(FIN_REGISTRO)) do a.ib:=a.ib+1;
				a.ib:=a.ib+1;
				if (a.ib <> Ord(FIN_BLOQUE)) then
				begin
					i:=a.ib;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.DNI);
					a.ib := a.ib +1;
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Apellido[1], a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.FechaNac);
					exito := true;
				end
				else begin
					if (not EoF(a.arch)) then
					begin
						BlockRead(a.arch, a.b, 1);
						a.ib:=1;
						i:=a.ib;
						while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
							a.ib := a.ib + 1;
						Move (a.b[i] , sx[1] , a.ib - i);
						Val (sx , a.p.DNI);
						a.ib := a.ib +1;
						i := a.ib;
						while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
							a.ib := a.ib + 1;
						Move (a.b[i] , a.p.Apellido[1], a.ib - i);
						a.ib := a.ib + 1;
						i := a.ib;
						while (a.b[a.ib] <> Ord(FIN_CAMPO)) do
							a.ib := a.ib + 1;
						Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
						a.ib := a.ib + 1;
						i := a.ib;
						while (a.b[a.ib] <> Ord(FIN_REGISTRO)) do
							a.ib := a.ib + 1;
						Move (a.b[i] , sx[1] , a.ib - i);
						Val (sx , a.p.FechaNac);
						exito := true;
					end
					else exito:=false;
				end;
			end;
			
			Procedure Respaldar (var A:ctlPersonas; nombre:String);
			var
				nuevo:File of tBloque;
				exito:boolean;
			begin
				Seek(A.arch,0);
				nombre:= nombre + '_respaldado';
				assign(nuevo, nombre);
				rewrite(nuevo, LongBloque);
				while (not EoF(A.arch)) do begin
					Siguiente(A, exito);
					if (exito) then BlockWrite(nuevo, A.b, 1);
				end;
				A.arch:= nuevo;   //# Esto no sÃ© si se puede hacer
			end;
			
			Procedure ImprimirBloque(var a:ctlPersonas);
			Begin
				Seek(a.arch, 0);
				while(not eof(a.arch)) do
				begin
					BlockRead(a.arch, a.b, 1);
					a.ib:=1;
					while (a.b[a.ib] <> Ord(FIN_BLOQUE)) do
					begin
						write(Chr(a.b[a.ib]));
						a.ib:=a.ib+1;
					end;
					writeln(Chr(a.b[a.ib]));
				end;
			End;
End.
