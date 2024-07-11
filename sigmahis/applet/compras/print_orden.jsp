.<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.awt.Color" %>
<%@ page import="java.util.ResourceBundle" %>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="vArticulo" scope="session" class="java.util.Vector" />

<%
/*=========================================================================
0 - SYSTEM ADMINISTRATOR
==========================================================================*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
Company com= new Company ();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

String codCat = request.getParameter("codCat");
String sala = request.getParameter("sala");
String id = request.getParameter("id");
String anio = request.getParameter("anio");
String num = request.getParameter("num");
String fp = request.getParameter("fp");
String wh = request.getParameter("wh");

if(sala == null) sala ="";

//----------------------------------------------- Company ---------------------------
sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1, nvl(fax, ' ') compFax1, digito_verificador other1, nvl(substr(replace(logo,'\\','/'),instr(replace(logo,'\\','/'),'/',-1)+1,length(replace(logo,'\\','/'))-instr(replace(logo,'\\','/'),'/',-1)),'NA') compLogo from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);

if (appendFilter == null) appendFilter = "";

sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, a.lugar_entrega as entrega, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, d.descripcion, to_char(a.monto_total,'999,999,999,990.00') as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(a.monto_pagado,'0.00') as monto_pago,a.tiempo_entrega as tiempo, to_char(a.sub_total,'9,999,999,990.00') as sub_total,  to_char(a.descuento,'9,999,999,990.00') as descuento,  to_char(a.itbm,'9,999,990.00') as itbm,  to_char(a.sub_total-nvl(a.descuento,0),'9,999,999,990.00') as sub_desc, b.ruc||'          D.V.: '||b.digito_verificador as ruc, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion as tipoOrden, f.descripcion||' '||e.especificacion||decode(e.cod_familia,7,'  * FAVOR INDICAR LA VIDA UTIL DEL ARTICULO' ,NULL) as articuloDesc, e.cod_familia|| '-' ||e.cod_clase|| '-' ||e.cod_articulo as codigoArt ,f.precio_venta, f.cod_medida as medida, e.cantidad, to_char(e.cantidad - nvl(e.entregado,'0'),'999,999,990') as pendiente, to_char(e.monto_articulo,'999,999,990.00') as montoArticulo, to_char((e.cantidad * e.monto_articulo),'999,999,999,990.00') as total,e.estado_renglon as estadoRenglon, a.explicacion, e.entregado as cantEntregada from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_detalle_compromiso e, tbl_inv_articulo f where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and A.compania = c.compania and a.compania = e.compania and a.num_doc = e.cf_num_doc and a.tipo_compromiso = e.cf_tipo_com and e.cod_familia = f.cod_flia and e.cod_clase = f.cod_clase and e.cod_articulo = f.cod_articulo and e.compania = f.compania and a.anio = e.cf_anio and a.tipo_compromiso = d.tipo_com and a.anio = "+anio+" and a.num_doc = "+num+" and a.status = 'A' and a.tipo_compromiso <> 3 and e.estado_renglon ='P' and a.compania = "+session.getAttribute("_companyId")+" order by a.cod_proveedor, a.anio, a.fecha_documento, a.num_doc";

  al = SQLMgr.getDataList(sql);

vArticulo.clear();


if(request.getMethod().equalsIgnoreCase("GET")) {

		String articulo_desc ="",articulo="", subT="", desc="", subDesc="", itbm="";
		String proveedor ="", ruc ="", factura="", entrega="", tiempo="", pago="";
		double total =0;
		int sub_total =0 ;
		int camas = 0 ,y=0 ;

		int maxLines = 55; //max lines of items

		int total_page =0;
		int cantidad=0;
		int cxarticulo =0;
		int extra_x_articulo =0,total_page_x_c=0;
		for(int z=0;z<al.size();z++)
		{
			CommonDataObject cdo1 = (CommonDataObject) al.get(z);
			if(proveedor == null || proveedor.trim().equals(""))
			{
					proveedor = cdo1.getColValue("nombre_proveedor");
					ruc = cdo1.getColValue("ruc");
					factura = cdo1.getColValue("numero_factura");
					entrega = cdo1.getColValue("entrega");
					tiempo = cdo1.getColValue("tiempo");
					pago = cdo1.getColValue("monto_total");
					itbm = cdo1.getColValue("itbm");
					subDesc = cdo1.getColValue("sub_desc");
					desc = cdo1.getColValue("descuento");
					subT = cdo1.getColValue("sub_total");
			}
			if(!vArticulo.contains(cdo1.getColValue("codigoArt")))
			{

				vArticulo.add(cdo1.getColValue("codigoArt"));

				if(z>0)
				{
						cxarticulo +=3;
						extra_x_articulo = (cxarticulo % maxLines) ;

						if(extra_x_articulo==0)
						{
								total_page += (cxarticulo / maxLines) ;
								total_page_x_c  = (cxarticulo / maxLines);
						}
						else
						{
						  	total_page += (cxarticulo / maxLines)+1;
								total_page_x_c =  (cxarticulo / maxLines)+1;
						}
						//System.out.println("-------------line x articulo = "+cxarticulo+"     extra_x_articulo=  "+extra_x_articulo+"    paginas x articulo  "+total_page_x_c);
						total_page_x_c=0;
						cxarticulo=0;
				}
				cantidad++;
			}
			cxarticulo++;


		}
		vArticulo.clear();

			//System.out.println("\\n -------------paginas x articulo en total "+total_page);


		int nItems = al.size()+(cantidad*4); //number of items
		int extraItems = nItems % maxLines;
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		if (extraItems == 0)
		   nPages = (nItems / maxLines);
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;
		if (total_page == 0) total_page = 1;
		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
		String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;
		boolean trueFalse= false;
		String folderName = "compras";
		String fileNamePrefix = "print_ordencompra";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		String year=fecha.substring(6, 10);
		String mon=fecha.substring(3, 5);
		String month = null;
		if(mon.equals("01")) month = "january";
		else if(mon.equals("02")) month = "february";
		else if(mon.equals("03")) month = "march";
		else if(mon.equals("04")) month = "april";
		else if(mon.equals("05")) month = "may";
		else if(mon.equals("06")) month = "june";
		else if(mon.equals("07")) month = "july";
		else if(mon.equals("08")) month = "august";
		else if(mon.equals("09")) month = "september";
		else if(mon.equals("10")) month = "october";
		else if(mon.equals("11")) month = "november";
		else month = "december";

		String day=fecha.substring(0, 2);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);
		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else {

			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

			int headerFooterFont = 4;
			StringBuffer sbFooter = new StringBuffer();

			//float leftRightMargin = 9.0f;
			//float topMargin = 13.5f;
			//float bottomMargin = 9.0f;

			 float leftRightMargin = 30.0f;
            float topMargin = 40.0f;
            float bottomMargin = 40.0f;


			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

	//Verificar
		int no2 = 0;

for (int j=1; j<=nPages; j++)
{
			Vector setHeader02=new Vector();
					setHeader02.addElement(".50");
					setHeader02.addElement(".50");


			Vector setInnerVal = new Vector();
        			setInnerVal.addElement("130");


			Vector setHeader0=new Vector();
					setHeader0.addElement(".2");
					setHeader0.addElement(".8");
					setHeader0.addElement(".2");

				 pc.setNoColumnFixWidth(setHeader0);

        	pc.createTable();
				pc.setFont(12, 1);
				pc.addImageCols(""+logoPath,30.0f,0);
				pc.setVAlignment(2);
				pc.addCols(com.getCompLegalName(),1, 1,15.0f);
				pc.addCols("",1,1,15.0f);
				pc.addTable();

				Vector setHeader1 = new Vector();
				setHeader1.addElement(".1000");
				pc.setNoColumnFixWidth(setHeader1);

				pc.createTable();
				pc.addBorderCols("1",0,1,1.5f,0.0f,0.0f,0.0f,5.0f);
				pc.addTable();

				Vector setHeader9=new Vector();
				setHeader9.addElement(".100");
				pc.setNoColumnFixWidth(setHeader9);

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("RUC."+" "+com.getCompRUCNo(),1,1);
				pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("Apdo."+" "+com.getCompPAddress()+" "+" "+" "+" "+" "+" "+" "+" Tels."+com.getCompTel1(),1,1);
				pc.addTable();
				
				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols(" TELEFONO: 305-6374   FAX: 305-6378 ",1,1);
				pc.addTable();
				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols(" ORDEN DE COMPRA ",1,1);
				pc.addTable();



			    pc.createTable();
			        pc.setFont(7, 0);
			        pc.addCols("Por: "+userName, 0, 1);
			        pc.addCols("Página: "+j+" de "+nPages, 2, 1);
			    pc.addTable();

				Vector setCol=new Vector();
				    setCol.addElement(".80");
					setCol.addElement(".20");

				Vector setHeader3=new Vector();
				    setHeader3.addElement(".15");
					setHeader3.addElement(".35");
					setHeader3.addElement(".20");
					setHeader3.addElement(".30");


				Vector setHeader2=new Vector();
					setHeader2.addElement(".15");
					setHeader2.addElement(".45");
					setHeader2.addElement(".10");
					setHeader2.addElement(".10");
					setHeader2.addElement(".10");
					setHeader2.addElement(".10");



				pc.setNoColumnFixWidth(setHeader2);

				pc.createTable();
					pc.setFont(7, 1);
					pc.addCols(" ", 0,6);
				pc.addTable();

				if(proveedor != null && !proveedor.trim().equals(""))
				{

						pc.setNoColumnFixWidth(setHeader3);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Proveedor :. :   ", 0,1);
							pc.addCols(" "+proveedor, 0,1);
							pc.addCols("Términos : ", 0,1);
							pc.addCols("", 2,1);
						pc.addTable();

							pc.setNoColumnFixWidth(setHeader3);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("R.U.C :. :   ", 0,1);
							pc.addCols(" "+ruc, 0,1);
							pc.addCols("Solicitud No. : ", 0,1);
							pc.addCols("", 2,1);
						pc.addTable();

							pc.setNoColumnFixWidth(setHeader3);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Lugar de Entrega :   ", 0,1);
							pc.addCols(" "+entrega, 0,1);
							pc.addCols("Orden de Compra No. :   ", 0,1);
							pc.addCols(""+anio+" - "+num, 0,1);
						pc.addTable();

						pc.setNoColumnFixWidth(setHeader3);
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addCols("Tiempo de Entrega :   ", 0,1);
							pc.addCols(" "+tiempo, 0,1);
							pc.addCols("Factura  No. :   ", 0,1);
							pc.addCols(""+factura, 0,1);
						pc.addTable();


						pc.setNoColumnFixWidth(setHeader2);
						pc.createTable();
						pc.setFont(7, 0, Color.red);
				  			pc.addBorderCols("CODIGO",0, 1, 0.5f, 0.5f, 0.5f, 0.5f);
							pc.addBorderCols("DESCRIPCION",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
							pc.addBorderCols("UNIDAD",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
							pc.addBorderCols("CANTIDAD",1, 1, 0.5f, 0.5f, 0.5f, 0.5f);
							pc.addBorderCols("PRECIO",2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
							pc.addBorderCols("TOTAL",2, 1, 0.5f, 0.5f, 0.5f, 0.5f);
						pc.addTable();
				trueFalse = false;
				}
				if (al.size()==0)
			  {
						pc.createTable();
							pc.addCols("No existe Registros para este Reporte ",1,9);
						pc.addTable();
				}
				else //al.size()
				{
						for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
						{
							 if(y<al.size())//recorrido de la lista
							 {
							  CommonDataObject cdo1 = (CommonDataObject) al.get(y);
								no2 += 1;



									pc.createTable();
										pc.setFont(6, 0);
											pc.addBorderCols(" "+cdo1.getColValue("codigoArt"),0, 1, 0.0f, 0.0f, 0.5f, 0.5f);
											pc.addBorderCols(" "+cdo1.getColValue("articuloDesc"),0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
											pc.addBorderCols(" "+cdo1.getColValue("medida"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
											pc.addBorderCols(" "+cdo1.getColValue("cantidad"),1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
											pc.addBorderCols(" "+cdo1.getColValue("montoArticulo"),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
											pc.addBorderCols(" "+cdo1.getColValue("total"),2, 1, 0.0f, 0.0f, 0.0f, 0.5f);
									  pc.addTable();
										sub_total ++;

										articulo = cdo1.getColValue("codigoArt");
										articulo_desc = cdo1.getColValue("articuloDesc");

							  }
									if (y<al.size())
									//if(y==al.size()-1)
									{

											pc.createTable();
												pc.setFont(8, 1,Color.red);
												pc.addCols("Total de Ordenes "+sub_total,0,4);
												pc.addTable();
												sub_total = 0;

												pc.createTable();
																pc.setFont(8, 1);
																pc.addCols("  ",0,4);
															pc.addTable();
															no2 += 2;
															i += 2;

												pc.createTable();
												pc.setFont(8, 1);
												pc.addCols("Total de Articulos   "+al.size(),0,4);
												pc.addTable();

									}

									y++;

									 if (y == al.size())
									 {
                                          for(int n=y;n<30;n++){
                                     		pc.setFont(8, 0);
                                     		pc.createTable();
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.5f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                  							pc.addTable();
               							 }

										 	pc.setFont(8, 0);
                                     		pc.createTable();
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                    						pc.addBorderCols(" ", 2, 1, 0.0f, 0.5f, 0.0f, 0.0f);
                  							pc.addTable();


											pc.setFont(8, 0);
                                     		pc.createTable();
                    						pc.addBorderCols("Explicación : ", 0, 1, 0.0f, 0.5f, 0.5f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.5f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols("Sub Total: ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols(" "+subT, 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                  							pc.addTable();

											pc.setFont(8, 0);
                                     		pc.createTable();
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.5f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols("Descuento: ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols(" "+desc, 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                  							pc.addTable();
											pc.setFont(8, 0);

                                     		pc.createTable();
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.5f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols("SUBTOTAL: ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols(" "+subDesc, 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                  							pc.addTable();

											pc.setFont(8, 0);
                                     		pc.createTable();
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.5f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols("ITBM: ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols(" "+itbm, 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                  							pc.addTable();

											pc.setFont(8, 0);
                                     		pc.createTable();
                    						pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.5f, 0.0f);
                    						pc.addBorderCols(" ", 0, 1, 0.5f, 0.0f, 0.0f, 0.5f);
                    						pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
											pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols("TOTAL : ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    						pc.addBorderCols(" "+pago, 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                  							pc.addTable();

									pc.setFont(8, 0);
                                    	pc.createTable();
                    					pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    					pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    					pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
										pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    					pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    					pc.addBorderCols(" ", 2, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                  					pc.addTable();


									pc.setFont(8, 0);
                                    	pc.createTable();
                    					pc.addBorderCols(" ENTREGA : _______________________________  RECIBE: ________________________________", 0, 3, 0.0f, 0.0f, 0.0f, 0.0f);
                    					pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
										pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    					pc.addBorderCols(" ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    				pc.addTable();

									pc.setFont(8, 0);
                                    pc.createTable();
                    				pc.addBorderCols(" APROBADO EN DEPARTAMENTO POR :  ", 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
                    				pc.addBorderCols(" ", 0, 4, 0.5f, 0.0f, 0.0f, 0.0f);
									pc.addTable();
									pc.setFont(8, 0);
                                    pc.createTable();
                    				pc.addBorderCols(" APROBADO EN GERENCIA DE SERV. ADMINISTRATIVOS POR :  ", 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
                    				pc.addBorderCols(" ", 0, 4, 0.5f, 0.0f, 0.0f, 0.0f);
									pc.addTable();

								pc.setFont(8, 0);
                                pc.createTable();
                    			pc.addBorderCols(" APROBADO EN GERENCIA GENERAL POR :  ", 0, 2, 0.0f, 0.0f, 0.0f, 0.0f);
                    			pc.addBorderCols(" ", 0, 4, 0.5f, 0.0f, 0.0f, 0.0f);
								pc.addTable();

								pc.setFont(8, 0);
                                pc.createTable();
                    			pc.addBorderCols(" USUARIO :  ", 0, 1, 0.0f, 0.0f, 0.0f, 0.0f);
                    			pc.addBorderCols(" "+userName, 0, 5, 0.0f, 0.0f, 0.0f, 0.0f);
								pc.addTable();

											}






									if ((i + 1) == nItems) break;
						}//End For i
					}//End else
						if((no2+2)<=maxLines)
						{
						}
						else
						{
							pc.addNewPage();
						}
				}//For j


	pc.close();
				response.sendRedirect(redirectFile);
		}
		}

%>