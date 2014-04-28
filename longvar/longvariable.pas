UNIT longvariable;
INTERFACE
         Const
              LongBloque = 1024;
              FIN_REGISTRO = '@';
              FIN_CAMPO = '#';
              FIN_BLOQUE = '*';
         Type
             tNroBloque = Word;
             tBloque = Array[1..LongBloque] of Byte;
             abPersonas = File of tBloque;
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
                         lpe: Byte;
                         p: tPersona;
             end;

             Procedure Crear(var a: ctlPersonas);
             Procedure Abrir(var a: ctlPersonas; modo: tEstado);
             Procedure Cerrar(var a: ctlPersonas);
             Function Libre(var a: ctlPersonas): tNroBloque;
             Procedure Cargar(var a:ctlPersonas);
             Procedure DevolverPersona (var a:ctlPersonas; var p:tpersona);
             Procedure Cargar(var a:ctlPersonas);
             Procedure Insertar (var a:ctlPersonas; var exito:boolean);
             Procedure Exportar(var a:ctlPersonas; nom:String);
             Procedure Eliminar(var a:ctlPersonas; dni:Longword; var exito:boolean);
             Procedure Recuperar(var a:ctlPersonas; dni:Longword; var exito:boolean);
             Procedure Modificar(var a:ctlPersonas; nom:String[20]; ape:String[20]; dni:Longword; fecha:Longword; var exito:boolean);
             Procedure Primero (var a : ctlPersonas ; var exito : boolean);
             Procedure Siguiente (var a : ctlPersonas ; var exito : boolean);
             Procedure Respaldar (a:ctlPersonas);

IMPLEMENTATION

              Procedure Crear(var a: ctlPersonas);
              begin
                   Rewrite(a.arch, LongBloque);
                   Rewrite(a.libres);
                   a.estado:=E;
                   a.ib:=1;
              end;
 
              Procedure Abrir(var a: ctlPersonas; modo: tEstado);
              begin
                   Reset(a.arch, LongBloque); Reset(a.libres);
                   a.estado:=modo;
                   if (modo=E) then
                   begin
                        Seek(a.arch, FileSize(a.arch)-1);
                        BlockRead(a.arch, a.b, 1);
                        Seek(a.libres, FileSize(a.libres)-1);
                        Read(a.libres, a.libre);
                        ib:=LongBloque - a.libre+1;
                   end
                   else if (modo=LE) then a.ib:=1;
              end;
 
              Procedure Cerrar(var a: ctlPersonas);
              begin
                   Close(a.arch);
                   Close(a.libres);
                   a.Estado:=C;
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
                 i: integer;
              begin
                   i:= 1;
                   act:= 1;
                   while (a.b[i] <> FIN_BLOQUE) do            i:= i+1;	// aca tendria que copiar tambien las marcas
                   while (a.pe[act] <> FIN_REGISTRO) do
                   begin
                        Move(a.pe[act], a.b[i], 1); // mueve el caracter de a.pe[act] a a.b[i] (un solo caracter)
                        i:= i+1;
                        act:= act+1;
                   end;
                   Move(FIN_REGISTRO, a.b[i], 1);
                   Move(FIN_BLOQUE, a.b[i+1], 1);
                   Seek(a.libres,(FileSize(a.arch)-1));
                   read(a.libres,a.libre);
                   a.libre:= a.libre - a.lpe;
                   Seek(a.libres,(FilePos(a.libres)-1));
                   write(a.libres,a.libre);
              end;

              Procedure EscribirEnBloqueNuevo(var a:ctlPersonas);
              begin
                   i:= 1;
                   while(a.pe[i] <> FIN_REGISTRO) do     //aca conviene que despues del while se ponga la marca FIN_BLOQUE
                   begin
                        Move(a.pe[i], a.b[i], 1);
                        i:= i+1;
                   end;
                   Move(FIN_REGISTRO, a.b[i], 1);
                   Move(FIN_BLOQUE, a.b[i+1], 1);
                   Seek(a.libres, FileSize(a.libres)));
                   a.libre:= longbloque-a.lpe-1;
                   write(a.libres,a.libre);
              end;

              Procedure Cargar(var a:ctlPersonas);
              begin
                   if (a.estado <> LE) then    a.estado:= LE;
                   Seek(a.arch, (FileSize(a.arch)-1));
                   BlockRead(a.arch, a.b, 1);
                   Empaquetar(a);
                   if (UltimoBloqueLibre(a)) then
                   begin
                        Seek(a.arch, (FilePos(a.arch)-1)); //vuelve al ultimo bloque a seguir escribiendo
                        EscribirEnBloqueUltimo(a);
                   end
                   else EscribirEnBloqueNuevo(a);
                   BlockWrite(a.arch, a.b, 1);
              end;
              
			Procedure Insertar (var a:ctlPersonas; var exito:boolean);
			var
				fin: boolean;
			Begin
				Seek(a.libres,0);
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
					BlockRead(a.arch, a.b);
					Move(a.pe[1], a.b[LongBloque-a.libre], a.lpe);
					Move(FIN_BLOQUE, a.b[LongBloque-a.libre+a.lpe], 1); //LongBloque-act+a.lpe+1??
					a.libre:= a.libre-a.lpe;
					write(a.libres,a.libre);
				end
				else	Cargar(a);
				exito:= true;
				End;
              
				Procedure Exportar(var a:ctlPersonas; nom:String);
				Var
					nue:Text;
					i:word;
					output, sx:String;
				Begin
					Rewrite(nue, nom);
					Seek(a.arch, 0);
					while (not EoF(a.arch)) do begin
						BlockRead(a.arch, a.b, 1);
						a.ib:=1;
						i:=a.ib;
						while(a.b[a.ib] <> FIN_BLOQUE) do begin
							while(a.b[a.ib] <> FIN_CAMPO) do 
								a.ib:=a.ib+1;
							Move (a.b[i] , sx[1] , a.ib - i);
							Val (sx , a.p.DNI);
							output:= 'DNI: ' + a.p.DNI + ' ';
							a.ib := a.ib +1;
							i := a.ib;
							while (a.b[a.ib] <> FIN_CAMPO) do
								a.ib := a.ib + 1;
							Move (a.b[i] , a.p.Apellido[1], a.ib - i);
							output:=output + 'Apellido: ' + a.p.Apellido + ' ';
							a.ib := a.ib + 1;
							i := a.ib;
							while (a.b[a.ib] <> FIN_CAMPO) do
								a.ib := a.ib + 1;
							Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
							output:= output + 'Nombres: ' + a.p.Nombres + ' ';
							a.ib := a.ib + 1;
							i := a.ib;
							while (a.b[a.ib] <> FIN_REGISTRO) do
								a.ib := a.ib + 1;
							Move (a.b[i] , sx[1] , a.ib - i);
							Val (sx , a.p.FechaNac);
							output := output + 'Fecha de Nacimiento: ' + a.p.FechaNac + '.';
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
					while ((a.b[a.ib] <> FIN_BLOQUE) and (not b)) do begin			// recorre el bloque buscando un dni igual
						i:=1;
						while ((a.b[a.ib] <> FIN_CAMPO) and (a.b[a.ib] = sx[i])) do begin   // realiza la comparacion
							i:=i+1;
							a.ib:=a.ib+1;
						end;
						if (a.b[a.ib] = FIN_CAMPO) then b:=true
						else begin
							while (a.b[a.ib] <> FIN_REGISTRO) do a.ib:=a.ib+1;			// si no lo encuentra se ubica en el registro siguiente
							a.ib:=a.ib+1;
						end;
					end;
				end;
				if (b) then begin
					act:=a.ib;					// 'act' es el indice de las posiciones a reacomodar
					a.ib:=a.ib-Length(sx)-1;		// 'a.ib' es el indice de la posicion donde empieza el registro a eliminar
					repeat act:=act+1; until (a.b[act] = FIN_REGISTRO);
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
				codigo:integer;
              begin
				b:=false;
				Str(dni, sx);
				while ((not EOF(a.arch)) and (not b)) do begin					// recorre el archivo buscando el bloque que contiene 'dni'
					BlockRead(a.arch, a.b, 1);
					a.ib:=1;
					while ((a.b[a.ib] <> FIN_BLOQUE) and (not b)) do begin			// recorre el bloque buscando un dni igual
						i:=1;
						while ((a.b[a.ib] <> FIN_CAMPO) and (a.b[a.ib] = sx[i])) do begin   // realiza la comparacion
							i:=i+1;
							a.ib:=a.ib+1;
						end;
						if (a.b[a.ib] = FIN_CAMPO) then b:=true
						else begin
							while (a.b[a.ib] <> FIN_REGISTRO) do a.ib:=a.ib+1;			// si no lo encuentra se ubica en el registro siguiente
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
					while (a.b[a.ib] <> FIN_CAMPO) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], a.p.Apellido[1], t);
					a.ib:=a.ib+1;
					i:=a.ib;
					t:=0;
					while (a.b[a.ib] <> FIN_CAMPO) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], a.p.Nombres[1], t);
					a.ib:=a.ib+1;
					i:=a.ib;
					t:=0;
					while (a.b[a.ib] <> FIN_REGISTRO) do begin
						a.ib:=a.ib+1;
						t:=t+1;
					end;
					Move(a.b[i], sx[1], t);
					Val(sx, a.p.FechaNac, codigo);
					a.ib:= checkpointer;
				end;
				exito:=b;
              end;
			
			//Franco
			Procedure CrearPersona(var P:tpersona; nom:String[20]; ape:String[20]; dnis:Longword; fecha:Longword);
			begin
				with P do
				begin
					Nombres:= nom;
					Apellido:= ape;
					DNI:= dnis;
					FechaNac:=fecha;
				end;
			end;
			
			Procedure Modificar(var a:ctlPersonas; nom:String[20]; ape:String[20]; dni:Longword; fecha:Longword; var exito:boolean);
			var
				i, tamanio, inicio:Word;
				cont, c:Longword;
				termino:boolean;
			begin
				Recuperar(a, dni, exito);
				if (exito) then // si no se encontro la persona a modificar exito=false
				begin		
					Empaquetar(a);
					tamanio:= a.lpe;   //tamaño en bytes del original
					CrearPersona(a.p, nom, ape, dni, fecha);
					Empaquetar(a);
					a.ib:=a.ib-SizeOf(dni);
					if(a.lpe<=tamanio) then 
					begin
						Move(a.pe[1],a.b[a.ib],a.lpe); 
						if(a.lpe<tamanio) then //si es igual no se debe hacer ningun corrimiento en el bloque
						begin
							i:=a.ib+a.lpe; //i se pone desde el ultimo lugar copiado, es decir desde 
							while(a.b[i]<> FIN_BLOQUE) do
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
						Seek(a.libre, FilePos(a.arch)-1);
						read(a.libres,a.libre);
						if(a.libre >= (tamanio-a.lpe)) then //entra en el bloque
						begin
							//hacer el corrimiento
							c:=a.lpe-tamanio; // saca la cantidad de veces a correr 1 posicion cada campo
							aux:=a.ib+tamanio-1;
							i:= aux;
							while(a.b[i]<> FIN_BLOQUE) do
								i:=i+1;
							while(i <> aux) do
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
				a.estado := L;
				Seek (a.arch,0);
				if not eof(a.arch) then begin
					blockread(a.arch,a.b,1);
					i := a.ib;
					while (a.b[a.ib] <> FIN_CAMPO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.DNI);
					a.ib := a.ib +1;
					i := a.ib;
					while (a.b[a.ib] <> FIN_CAMPO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Apellido[1], a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> FIN_CAMPO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> FIN_REGISTRO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.FechaNac);
					exito := true;
				end
				else exito := false;
			end;
	
			// Bianca
			Function HayEspacio(n:ctlPersonas):boolean;
			var
				a:ctlPersonas;
			begin
				Seek(n.libres,fileSize(n.libres)-(1));
                Read(n.libres,n.libre);
				Seek(n.libres,0);
                HayEspacio:= (n.libre>=a.lpe); // si hay lugar en el ultimo bloque de n
			end;

			Procedure EscribirEnBloque(var n:ctlPersonas,a:ctlPersonas);  
			var
				i: integer; act:integer;
			begin
				i:= 1; n.ib:= LongBloque - n.libres+1;     //inicializacion del puntero de n. **
				while (a.b[i] <> FIN_BLOQUE) do act:=1;           	
					while (a.pe[act] <> FIN_REGISTRO) do //mientras nose termine el bloque de a.
                    begin
                        Move(a.pe[act],n.b[i], 1); // mueve el caracter de a.pe[act] a el blocke de n (un solo caracter)
                        i:= i+1;
                        act:= act+1;
					end;	
				n.libre:= n.libre - a.lpe;       //actualizo el archivo de libres de  n. **			
			end;
			  
			Procedure Respaldar (a:ctlPersonas);
			var
				n: ctlPersonas;   
			begin   
				Assing(n.arch,'archivoRespaldado');   
				Crear(n); 
				n.estado:= LE;
				reset(a.arch,longBloque);   //abre el archivo a.
				a.ib:=1; Seek(a.libres,0)
				if (a.estado= LE) THEN begin
					while(not EoF(a.arch))do begin
						BlockRead(a.arch, a.b, 1);
						read(a,libres,a.libre);
						if(a.libre <> 0 )then begin
							Seek(n.arch, (FileSize(n.arch)-1)); //ultimo bloque de n
							if (HayEspacio(n)then EscribirEnBloque(n,a);   
							else    Seek(n.arch, (FileSize(n.arch))); //sobre escribo eof, nuevo bloque.
							EscribirEnBloque(n,a);
						end;
						BlockWrite(a.b,n.b,a.lpe); 
					end;
				a.libres:= filepos(a.libres)+1;
				a.ib:= a.ib + 1; //avanzo al proximo bloque de a.
				end; 
				close(a.arch);
				close(n.arch); 
			end;
				
			Procedure Siguiente (var a : ctlPersonas ; var exito : boolean);
			var
				i : word;
				sx : string;
			begin
				while(a.b[a.ib] <> FIN_REGISTRO) do a.ib:=a.ib+1;
				a.ib:=a.ib+1;
				if (a.ib <> FIN_BLOQUE) then
				begin
					i:=a.ib;
					while (a.b[a.ib] <> FIN_CAMPO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , sx[1] , a.ib - i);
					Val (sx , a.p.DNI);
					a.ib := a.ib +1;
					i := a.ib;
					while (a.b[a.ib] <> FIN_CAMPO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Apellido[1], a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> FIN_CAMPO) do
						a.ib := a.ib + 1;
					Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
					a.ib := a.ib + 1;
					i := a.ib;
					while (a.b[a.ib] <> FIN_REGISTRO) do
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
						while (a.b[a.ib] <> FIN_CAMPO) do
							a.ib := a.ib + 1;
						Move (a.b[i] , sx[1] , a.ib - i);
						Val (sx , a.p.DNI);
						a.ib := a.ib +1;
						i := a.ib;
						while (a.b[a.ib] <> FIN_CAMPO) do
							a.ib := a.ib + 1;
						Move (a.b[i] , a.p.Apellido[1], a.ib - i);
						a.ib := a.ib + 1;
						i := a.ib;
						while (a.b[a.ib] <> FIN_CAMPO) do
							a.ib := a.ib + 1;
						Move (a.b[i] , a.p.Nombres[1] , a.ib - i);
						a.ib := a.ib + 1;
						i := a.ib;
						while (a.b[a.ib] <> FIN_REGISTRO) do
							a.ib := a.ib + 1;
						Move (a.b[i] , sx[1] , a.ib - i);
						Val (sx , a.p.FechaNac);
						exito := true;
					end
					else exito:=false;
				end;
			end;
End.
