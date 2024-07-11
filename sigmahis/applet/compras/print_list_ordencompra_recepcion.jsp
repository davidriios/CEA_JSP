<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
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
<jsp:useBean id="vProv" scope="session" class="java.util.Vector" />

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
ArrayList tal = new ArrayList();
Company com= new Company ();

String sql = "";
String descripcion="";
String appendFilter = request.getParameter("appendFilter");
System.out.println("\n\n appendFilter="+appendFilter+"\n\n");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();



//----------------------------------------------- Company ---------------------------
sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");
com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);

if (appendFilter == null) appendFilter = "";


	sql = "SELECT a.anio, a.tipo_compromiso, a.num_doc, a.anio||'-'||a.num_doc as ordenNum, a.compania, to_char(fecha_documento,'dd/mm/yyyy') fecha_documento, a.status, d.descripcion, a.monto_total as monto_total, a.numero_factura, to_char(a.fecha_entrega_vencimiento,'dd/mm/yyyy') as fechaVence,nvl(a.monto_pagado,'0.00') as monto_pago, decode(substr(a.tipo_pago,0,2),'CR','CREDITO','CO','CONTADO') as tipo_pago, decode(a.status,'A','APROBADO','N','ANULADO','P','PENDIENTE','R','PROCESADO','T','TRAMITE') desc_status, '[ '||nvl(a.cod_proveedor, 0) || '] ' || nvl(b.nombre_proveedor, ' ')as nombre_proveedor, nvl(a.cod_almacen, 0) || ' ' || c.descripcion almacen_desc, to_char(a.monto_total - nvl(a.monto_pagado,'0.00'),'999,999,990.00') as saldo, a.cod_proveedor, d.descripcion as tipoOrden, f.descripcion as articulo, e.cantidad, to_char(e.cantidad - nvl(e.entregado,'0'),'999,999,990.00') as pendiente, e.monto_articulo as montoArticulo, e.estado_renglon as estadoRenglon, a.explicacion, e.entregado as cantEntregada "
+ " from tbl_com_comp_formales a, tbl_com_proveedor b, tbl_inv_almacen c, tbl_com_tipo_compromiso d, tbl_com_detalle_compromiso e, tbl_inv_articulo f "
+ " where a.cod_proveedor = b.cod_provedor(+) and a.cod_almacen = c.codigo_almacen and "
+ " a.compania = c.compania and a.compania = e.compania and a.num_doc = e.cf_num_doc and a.tipo_compromiso = e.cf_tipo_com and e.cod_familia = f.cod_flia and e.cod_clase = f.cod_clase and e.cod_articulo = f.cod_articulo and e.compania = f.compania and a.anio = e.cf_anio and a.tipo_compromiso = d.tipo_com and a.anio = "+anio+" and a.num_doc = "+id+" and a.status = 'A' and a.tipo_compromiso <> 3 and e.estado_renglon ='P' and a.compania = "+session.getAttribute("_companyId") + appendFilter+" order by a.cod_proveedor, a.anio, a.fecha_documento, a.num_doc";


al = SQLMgr.getDataList(sql);


if(request.getMethod().equalsIgnoreCase("GET")) {
double totAcr =0 ;
double totPago =0 ;
double totSaldo =0 ;
double total =0 ;
String prov="";
String codProv="";
		int maxLines = 60; //max lines of items
		int cProv =0;
		int y = 0;
		int total_page =0;
		int extraProv =0,total_page_p=0;
		//calculating number of page


		for(int z=0;z<al.size();z++)
		{
			CommonDataObject cdo1 = (CommonDataObject) al.get(z);
			if(prov == null || prov.trim().equals(""))
			{
					prov = cdo1.getColValue("nombre_proveedor");
					codProv = cdo1.getColValue("cod_proveedor");

			}
			if(!vProv.contains(cdo1.getColValue("cod_proveedor")))
			{

				vProv.add(cdo1.getColValue("cod_proveedor"));

					if(z>0)
				{
						cProv +=4;
						extraProv = (cProv % maxLines) ;

						if(extraProv==0)
						{
								total_page += (cProv / maxLines) ;
								total_page_p  = (cProv / maxLines);
						}
						else
						{
						  	total_page += (cProv / maxLines)+1;
								total_page_p =  (cProv / maxLines)+1;
						}

						total_page_p=0;
						cProv=0;
				   }
				}
				cProv++;
		}

		vProv.clear();


	    int trueFalse=0;
		int nItems = al.size(); //number of items
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

		String folderName = "compras";
		String fileNamePrefix = "print_list_ordencompra_normal";
		String fileNameSuffix = "";
		String fecha = cDateTime;
		//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
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
		//System.out.println("Year is: "+year+" Month is: "+month+" Day is: "+day);
		String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
		String dir=java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/"+folderName.trim();
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);
//System.out.println("******* directory="+directory);
		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else {

			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

			int headerFooterFont = 4;
			//System.out.println("******* else");
			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;


			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont,      logoMark, logoPath, statusMark, statusPath);

	//Verificar
		int no = 0;
		int cp = 0;

		String desc="";
for (int j=1; j<=total_page; j++)
{

			trueFalse=0;
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
				  pc.addCols("Compras",1,1);
				pc.addTable();

			    pc.createTable();
			        pc.setFont(7, 0);
			        pc.addCols("Por: "+userName+"                        Fecha :  "+fecha, 0, 1);
			        pc.addCols("Página: "+j+" de "+nPages, 2, 1);
			    pc.addTable();

//				pc.createTable();
//					pc.addCols(" ", 0,4,5f);
//				pc.addTable();

				Vector setHeader2=new Vector();
				  setHeader2.addElement(".07");
					setHeader2.addElement(".07");
					setHeader2.addElement(".15");
					setHeader2.addElement(".08");
					setHeader2.addElement(".08");
					setHeader2.addElement(".15");
					setHeader2.addElement(".08");
					setHeader2.addElement(".08");
					setHeader2.addElement(".08");
					setHeader2.addElement(".08");
					setHeader2.addElement(".08");
				pc.setNoColumnFixWidth(setHeader2);

				pc.createTable();
					pc.setFont(7, 1);
					pc.addCols("", 0,4);
				pc.addTable();


				if(prov != null && !prov.trim().equals(""))
				{
						pc.createTable();
							pc.setFont(8, 1,Color.blue);
							pc.addBorderCols("Proveedor :  ", 0,1);
							pc.addBorderCols(""+prov, 0,10);
						pc.addTable();
						pc.createTable();
						pc.setFont(7, 0);
							pc.addCols(" ",0,11);
						pc.addTable();
				}



				pc.createTable();
				  pc.addBorderCols("Fecha",1);
					pc.addBorderCols("Compromiso",1);
					pc.addBorderCols("Tipo de Compromiso",1);
					pc.addBorderCols("Fecha Vencimiento",1);
					pc.addBorderCols("Tipo de Pago",1);
					pc.addBorderCols("Almacén",1);
					pc.addBorderCols("No. de Factura",1);
					pc.addBorderCols("Estado",1);
					pc.addBorderCols("Monto Total",2);
					pc.addBorderCols("Monto Pagado",2);
					pc.addBorderCols("Saldo",2);
				pc.addTable();


				if (al.size()==0)
				{
					pc.createTable();
						pc.addCols("No existe la Orden de Compra seleccionada",1,11);
					pc.addTable();
				}
				else
				{
					for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)

								{

						 if(y<al.size())
							 {
							  CommonDataObject cdo1 = (CommonDataObject) al.get(y);
								no += 1;


								if(!vProv.contains(cdo1.getColValue("cod_proveedor")))
								{
									no += 1;
									i   += 1;
									vProv.add(cdo1.getColValue("cod_proveedor"));
								}
							pc.createTable();
							pc.setFont(7, 0);
							    pc.addCols(" "+cdo1.getColValue("fecha_documento"),1,1);
								pc.addCols(" "+cdo1.getColValue("anio")+" - "+cdo1.getColValue("num_doc"),1,1);
								pc.addCols(" "+cdo1.getColValue("descripcion"),0,1) ;
								pc.addCols(" "+cdo1.getColValue("fechaVence"),1,1) ;
								pc.addCols(" "+cdo1.getColValue("tipo_pago"),0,1) ;
								pc.addCols(" "+cdo1.getColValue("almacen_desc"),0,1);
								pc.addCols(" "+cdo1.getColValue("numero_factura"),1,1);
								pc.addCols(" "+cdo1.getColValue("desc_status"),0,1) ;
								pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto_total")),2,1);
								pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("monto_pago")),2,1);
								pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("saldo")),2,1);
							pc.addTable();
							    //desc=cdo1.getColValue("nombre_proveedor");
								prov=cdo1.getColValue("nombre_proveedor");
								if(prov != null && !prov.trim().equals(""))
				                     {

								totAcr += Double.parseDouble(cdo1.getColValue("monto_total"));
								totPago += Double.parseDouble(cdo1.getColValue("monto_pago"));
								totSaldo += Double.parseDouble(cdo1.getColValue("saldo"));
							       }
								if(al.size()-1 >= y+1)
								{

									CommonDataObject cdo2 = (CommonDataObject) al.get(y+1);
									if(!vProv.contains(cdo2.getColValue("cod_proveedor")))
									{
										prov = cdo2.getColValue("nombre_proveedor");
									pc.createTable();
									pc.setFont(8, 1);
									pc.addCols("Total por Proveedor  : ",2,8);
									pc.addCols(" "+CmnMgr.getFormattedDecimal(totAcr),2,1);
									pc.addCols(" "+CmnMgr.getFormattedDecimal(totPago),2,1);
									pc.addCols(" "+CmnMgr.getFormattedDecimal(totSaldo),2,1);

									pc.addTable();
									total += totAcr;
									totAcr = 0.00;
									totPago = 0.00;
									totSaldo = 0.00;
									no += 1;
									i +=1;

									for (int k=i; k<(maxLines * j); k++)
											{
											pc.createTable();
											pc.setFont(8, 1);
											pc.addCols("  ",0,11);
											pc.addTable();
											no++;
											}

										i = (maxLines * j);

									}
								}

							 }//if (y<al.size())


							y++;

							if ((i + 1) == nItems)
								{
						  			break;
								 }

						}//End For
					}//End Else

					if((no+2)<=maxLines){
					}else{
						pc.addNewPage();
					}
				//}//end else

			}//End For

	pc.close();
				response.sendRedirect(redirectFile);
		}
		}

%>
