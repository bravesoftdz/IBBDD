program ejer6;

uses arch, crt;

Procedure Menu(var op:char);
begin
     writeln('-------------------Elija la opci�n deseada-----------------');
     writeln();
     writeln('1- Crear Archivo. ');
     writeln('2- Cargar una nueva persona al final del archivo. ');
     writeln('3- Ver la primera persona del archivo. ');
     writeln('4- Avanzar a la siguiente persona en el archivo. ');
     writeln('5- Buscar persona. ');
     writeln('6- Crear un documento de texto con los datos del archivo. ');
     writeln('7- Insertar persona en alg�n lugar libre del archivo. ');
     writeln('8- Eliminar persona. ');
     writeln('9- Modificar persona. ');
     writeln('c- Crear una nueva versi�n del archivo sin espacios libres. ');
     writeln('a- Abrir un archivo existente. ');
     writeln('x- Cerrar archivo. ');
     writeln('s- Salir. ');
     op:=readkey;
end;

var
   A: apersonas;
   resultado: boolean;
   archi: Text;
   opcion:char;
   dni, fecnac_dia, fecnac_mes, fecnac_ano: Longword;
   P:tpersona;
   info_nom, info_ape, nombre, nom, ape, nomlib: String;

begin
     Menu(opcion);
     while (opcion<>'s') do
     begin
          case opcion of
               '1':     begin
                           write('Escriba el nombre que desea darle al archivo (m�ximo 20 caracteres): ');
                           readln(nombre);
                           write('Escriba el nombre que desea darle al archivo libres(m�ximo 20 caracteres): ');
                           readln(nomlib);
                           CrearArchivo(A,nombre,nomlib);
                           Clrscr;
                      end;
               '2':     begin
                             Cargar(A);
                             Clrscr;
                        end;
               '3':     begin
                           Primero(A,resultado);
                           if (resultado) then
                           begin
                                writeln('La operaci�n fue exitosa. ');
                                writeln('Pulsar un caracter para ver los datos de la persona encontrada. ');
                                readkey;
                                DevolverPersona(A,P);
                                Consultar_nombre(info_nom, P);
                                Consultar_apellido(info_ape, P);
                                writeln('Nombre: ', info_nom, ' Apellido: ', info_ape, ' DNI: ', Consultar_dni(P), ' Fecha de Nacimiento: ', Consultar_fechanac_dia(P), '/', Consultar_fechanac_mes(P), '/', Consultar_fechanac_ano(P), '.');
                            end
                           else
                           begin
                                writeln('No se pudo ejecutar la operaci�n, hubo un error. ');
                             end;
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                      end;
               '4':     begin
                           Siguiente(A,resultado);
                           if (resultado) then
                           begin
                               DevolverPersona(A,P);
                               Consultar_nombre(info_nom, P);
                               Consultar_apellido(info_ape, P);
                               writeln('Nombre: ', info_nom, ' Apellido: ', info_ape, ' DNI: ', Consultar_dni(P), ' Fecha de Nacimiento: ', Consultar_fechanac_dia(P), '/', Consultar_fechanac_mes(P), '/', Consultar_fechanac_ano(P), '.');
                               writeln();
                               writeln('Se pudo avanzar correctamente a la siguiente persona del archivo. ');
                           end
                           else
                           begin
                                writeln('Ha ocurrido un error. Es posible que no exista otra persona en el archivo luego de la actual. ');
                           end;
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                      end;
               '5':     begin
                           write('Escriba el DNI de la persona que desea conocer su informaci�n: ');
                           readln(dni);
                           Recuperar(A,dni,resultado);
                           if (resultado) then
                           begin
                                writeln('La operaci�n fue exitosa. ');
                                writeln('Pulsar un caracter para ver los datos de la persona con dni ', dni, ': ');
                                readkey;
                                DevolverPersona(A,P);
                                Consultar_nombre(info_nom, P);
                                Consultar_apellido(info_ape, P);
                                writeln('Nombre: ', info_nom, ' Apellido: ', info_ape, ' DNI: ', Consultar_dni(P), ' Fecha de Nacimiento: ', Consultar_fechanac_dia(P), '/', Consultar_fechanac_mes(P), '/', Consultar_fechanac_ano(P), '.');
                           end
                           else writeln('Ha ocurrido un error. Es posible que la persona que desea encontrar no se encuentre en el archivo. ');
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                      end;
               '6':     begin
                           write('Escriba un nombre para el documento de texto a crear (sin la extensi�n .txt): ');
                           readln(nombre);
                           Exportar(A,archi,nombre);
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                      end;
               '7':     begin
                           Insertar(A,resultado);
                           if (resultado) then   writeln('La persona fue cargada con �xito. ')
                           else writeln('Ha ocurrido un error. Es posible que exista una persona con el mismo dni o que el archivo se encuentre lleno. ');
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                        end;
               '8':     begin
                           write('Escriba el DNI de la persona que desea eliminar de la lista: ');
                           readln(dni);
                           Eliminar(A,dni,resultado);
                           if (resultado) then       writeln('La persona con dni ', dni, ' fue eliminada del archivo correctamente. ')
                           else           writeln('Ha ocurrido un error. Es posible que no exista ninguna persona con dni ', dni, ' en el archivo. ');
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                      end;
               '9':     begin
                           write('Escriba el dni de la persona que desea modificar: ');
                           readln(dni);
                           writeln('Escriba los nuevos datos para la persona a modificar: ');
                           write('Nombre: ');
                           readln(nom);
                           write('Apellido: ');
                           readln(ape);
                           writeln('Fecha de nacimiento: ');
                           write('Dia: ');
                           readln(fecnac_dia);
                           write('Mes: ');
                           read(fecnac_mes);
                           write('Ano: ');
                           readln(fecnac_ano);
                           Modificar(A,nom,ape,dni,fecnac_dia,fecnac_mes,fecnac_ano,resultado);
                           if (resultado) then                       writeln('El archivo ha sido modificado exitosamente. ')
                           else           writeln('Ha ocurrido un error. Es posible que la persona con dni ', dni, ' no se encuentre en el archivo');
                           writeln('Pulse ENTER para continuar. ');
                           readln();
                           Clrscr;
                      end;
               'c':    begin
                            write('Escriba el nombre con el que desea crear su archivo respaldado: ');
                            readln(nombre);
                            Respaldar(A, nombre);
                            writeln('Se ha creado un archivo sin espacios libres con el nombre: ', nombre, '_respaldado. ');
                            writeln('Pulse ENTER para continuar. ');
                            readln();
                            Clrscr;
                       end;
               'a':   begin
							writeln('Indique la informacion del archivo que desea abrir: ');
							write('Nombre del archivo: ');
							readln(nombre);
							write('Nombre del archivo libres: ');
							readln(nomlib);
							Abrir(A,nombre,nomlib);
                            writeln('Pulse ENTER para continuar. ');
                            readln();
                            Clrscr;
						end;
               'x':     begin
                             Cerrar(A);
                             writeln('El archivo ha sido cerrado exitosamente. ');
                             writeln('Pulse ENTER para continuar. ');
                             readln();
                             Clrscr;
                        end
		      else
				begin
					if (opcion <> 's') then
                    begin
						writeln('Indique una opci�n v�lida. ');
                        Menu(opcion);
                    end
                    else
                        writeln('La ejecuci�n del programa ha finalizado correctamente. ');
           	    end;
           	  end;
           	  Menu(opcion);
     end;
end.










