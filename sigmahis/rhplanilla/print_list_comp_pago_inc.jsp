<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" /> 
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>

<%

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
ArrayList alExtra = new ArrayList();
ArrayList alDesc = new ArrayList();
Company com= new Company ();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String empId = request.getParameter("empId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id");  
String compania = (String) session.getAttribute("_companyId");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String userId = UserDet.getUserId();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
 

if (appendFilter == null) appendFilter = "";

	sql = "select to_char(a.sal_bruto,'999,999,990.00') as salBruto, to_char(a.sal_neto,'999,999,990.00') as salNeto, to_char(a.sal_ausencia,'999,999,990.00') as salAus, nvl(a.extra,00) extra, to_char(a.seg_social,'999,990.00') as segSoc, to_char(a.seg_educativo,'999,990.00') as segEdu, to_char(a.imp_renta,'999,990.00') as impRen, to_char(a.fondo_com,'999,990.00') as fonCom, to_char(a.tardanza,'999,990.00') tardanza, to_char(a.ausencia,'999,990.00') ausencia, nvl(a.otras_ded,00) as deduc, nvl(to_char(a.total_ded,'999,999,990.00') ,0) totDed, nvl(to_char(a.total_ded + a.otros_egr,'999,999,990.00'),0) as totDeduc, to_char(a.dev_multa,'999,990.00') as devMul, to_char(a.comision,'999,990.00'), to_char(a.gasto_rep,'99,999,990.00') as gasRep, to_char(a.ayuda_mortuoria,'999,990.00') as aMor, to_char(a.otros_ing,'999,999,990.00') as otroIng, to_char(a.otros_egr,'999,999,990.00') as otroEg, to_char(a.alto_riesgo,'999,990.00') as altRiesgo, to_char(a.bonificacion,'999,990.00'), to_char(a.extra,'999,999,990.00') as extra, to_char(a.prima_produccion,'999,999,990.00') as prima, to_char(a.aguinaldo_gasto,'999,990.00') as aguiGas, to_char(a.imp_renta_gasto,'999,990.00') as impGasto, a.cheque_pago as cheque, to_char(a.seg_social_gasto,'999,990.00') as ssGasto, to_char(to_number(nvl(a.sal_ausencia,0.00))+to_number(nvl(a.gasto_rep,0.00))+to_number(nvl(a.alto_riesgo,0.00)) + to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.bonificacion,0.00))+to_number(nvl(a.comision,0.00))+to_number(nvl(a.extra,0.00)) + to_number(nvl(a.otros_ing,0.00)),'999,999,990.00') as salBruto, to_char(to_number(nvl(a.alto_riesgo,0.00)) + to_number(nvl(a.prima_produccion,0.00))+to_number(nvl(a.bonificacion,0.00))+to_number(nvl(a.comision,0.00))+to_number(nvl(a.extra,0.00)) + to_number(nvl(a.otros_ing,0.00)),'999,999,990.00') as ingTotComp, to_char(to_number(nvl(a.seg_educativo,0.00)) + to_number(nvl(a.otros_egr,0.00)) +to_number(nvl(a.otras_ded,0.00)),'999,999,990.00') as egrTotComp,to_char(a.salario_especie,'999,999,990.00') as salEsp, to_char(a.seg_social_especie,'999,990.00') as ssEsp, periodo_xiiimes as decimo, a.num_empleado as numEmpleado, to_char(a.num_cheque,'0000000') as numCheque, f.descripcion seccion, to_char(c.fecha_pago,'dd/mm/yyyy') as fechaPago, to_char(c.fecha_inicial,'dd-mm-yyyy') as fechaInicial, e.cedula1 cedula, f.codigo, e.num_ssocial, to_char(c.fecha_final,'dd/mm/yyyy') as fechaFinal, c.estado, e.nombre_empleado as nomEmpleado, g.denominacion cargo, to_char(a.rata_hora,'999,990.00') as rataHora, e.tipo_renta||'-'||to_char(e.num_dependiente,'990') as tipoRenta, ltrim(d.nombre,18)||' del '||c.fecha_inicial||' al '||c.fecha_final as descripcion, e.num_cuenta, to_char(a.salario_base/2,'999,999,990.00') salarioBase, e.emp_id, round(MONTHS_BETWEEN (to_date(c.fecha_final,'dd/mm/yyyy') , to_date(e.fecha_ingreso,'dd/mm/yyyy')) * 1.5  ) as vac from tbl_pla_pago_empleado a, vw_pla_empleado e, tbl_pla_planilla_encabezado c, tbl_pla_planilla d, tbl_pla_cargo g, tbl_sec_unidad_ejec f where a.emp_id = e.emp_id and a.cod_compania = e.compania and a.cod_compania = c.cod_compania and a.cod_planilla = c.cod_planilla and a.num_planilla = c.num_planilla and c.cod_planilla = d.cod_planilla and c.cod_compania = d.compania and a.anio = c.anio and a.cod_compania = f.compania and nvl(e.ubic_depto,e.ubic_seccion) = f.codigo and a.cod_compania = g.compania and e.cargo = g.codigo  and a.num_planilla="+num+" and a.cod_planilla="+cod+" and a.anio = "+anio+ " and a.cod_compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by e.ubic_fisica, e.num_empleado";
al = SQLMgr.getDataList(sql);

System.err.println(sql);

	

if(request.getMethod().equalsIgnoreCase("GET")) {

		int maxLines = 15; //max lines of items
		int nItems = al.size(); //number of items
		System.out.print("\n\n Items "+nItems+"\n\n");
		int extraItems = nItems % maxLines;
		System.out.print("\n\n extraItems "+extraItems+"\n\n");
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page
		
		//****************************************************
		// Calcular el número de páginas que tendrá el reporte
		//****************************************************
		if (extraItems == 0)
		   nPages = (nItems / maxLines);
			//System.out.print("\n\n nPages "+nPages+"\n\n");
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;
		String logoPath = java.util.ResourceBundle.getBundle("path").getString("companyimages")+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		
		String statusPath = "";
		boolean logoMark = false;
		boolean statusMark = false;
	
		String folderName = "rhplanilla";  
		String fileNamePrefix = "print_list_comp_pago_inc";
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
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+userId+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		
					
			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;
			
			int headerFooterFont = 4;
			int width = 612;
			int height = 396;
			boolean isLandscape = false;
			StringBuffer sbFooter = new StringBuffer();
				
			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;
						
				
			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);

			
	//Verificar
		int no = 0;				
		int lCounter = 0;
		int pCounter = 1;
		float cHeight = 5.5f;
			int listSize=8;
		
		
					
for (int j=1; j<=nPages; j++)
{
			Vector setHeader0=new Vector();
					   setHeader0.addElement(".2");
					   setHeader0.addElement(".8");
					   setHeader0.addElement(".2");
			
				Vector setHeader2=new Vector();
					setHeader2.addElement(".25");
					setHeader2.addElement(".10");	
					setHeader2.addElement(".15");
					setHeader2.addElement(".05");
					setHeader2.addElement(".25");
					setHeader2.addElement(".10");
					setHeader2.addElement(".10");										
		
				
																													
				if (al.size()==0) {
						pc.createTable();
							pc.addCols("No existe el código seleccionado",1,5);
						pc.addTable();

						}
				else{
					if (al.size() > 0)
					{
						//for(int i=0;i<maxLines;i++)
						for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
						{
						 CommonDataObject			cdo1 = (CommonDataObject) al.get(i);
	 
							no ++;			
					pc.setNoColumnFixWidth(setHeader0);
				pc.createTable();
				
				pc.setFont(9, 1);
					pc.addCols("          Depto :  "+cdo1.getColValue("codigo")+"  "+cdo1.getColValue("seccion"),0,3);
				pc.addTable();
					
				pc.createTable();
				pc.setFont(9, 1);
					pc.addCols("          Colaborador : "+cdo1.getColValue("numEmpleado")+"    "+cdo1.getColValue("nomEmpleado"),0,2);
					pc.addCols("Cédula : "+cdo1.getColValue("cedula"),0,1);
				pc.addTable();
				/*
				pc.createTable();
				pc.setFont(6, 1);
					pc.addCols("   "+cdo1.getColValue("cargo")+"    "+cdo1.getColValue("tipoRenta"),0,2);
					pc.addCols("Seg : "+cdo1.getColValue("num_ssocial"),0,1);
				pc.addTable();
				*/
				pc.createTable();
					pc.setFont(9, 0, Color.black);					
					pc.addCols(" ", 0,3);
				pc.addTable();
										
				Vector setHeader3 = new Vector();
				setHeader3.addElement(".1000");
				pc.setNoColumnFixWidth(setHeader3);
				
										
				/*
				pc.createTable();
					pc.setFont(12, 1);
					pc.addImageCols(""+logoPath,30.0f,1);
				pc.addTable();
				
				pc.createTable();
					pc.setFont(12, 1);
						pc.addCols(""+_comp.getNombre(),1, 1);
				pc.addTable();
				*/		
	
				pc.createTable();
					pc.setFont("COURIER",9, 0, Color.black);				
					pc.addCols("COMPROBANTE DE PAGO", 0,1);
				pc.addTable();
								
				
					pc.setNoColumnFixWidth(setHeader2);			
				pc.createTable();
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols(""+cdo1.getColValue("descripcion"),1,7);
				pc.addTable();	
				
				pc.createTable();
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols("",0,1);
					pc.addCols(""+cdo1.getColValue("nomEmpleado"),1,4);
					pc.addCols("",0,2);
				pc.addTable();		
														
				pc.createTable();	
					pc.addCols("# de Empleado  : "+cdo1.getColValue("numEmpleado"),1,1);
					pc.addCols(" "+cdo1.getColValue("seccion"),1,4);													
					pc.addCols("Fecha Pago  :"+cdo1.getColValue("fechaPago"),1,2);
				pc.addTable();	
					
				pc.createTable();	
					pc.addCols("",1,1);
					pc.addCols(" "+cdo1.getColValue("cargo"),1,4);													
					pc.addCols("",1,2);
				pc.addTable();				
							
				pc.createTable();	
					pc.addCols("Clave de Renta  : "+cdo1.getColValue("tipoRenta"),1,1);
					pc.addCols("Rata x Hora  : "+cdo1.getColValue("rataHora"),1,2);	
					pc.addCols("Cuenta : "+cdo1.getColValue("num_cuenta"),1,2);												
					pc.addCols("# Ck/Tal : "+cdo1.getColValue("numCheque"),1,2);
				pc.addTable();	
				
				pc.createTable();	
					pc.addBorderCols("* * * * I N G R E S O S  * * * * ",1,4);
					pc.addBorderCols("* * * *  E G R E S O S * * * * ",1,3);													
				pc.addTable();
				
					
				pc.createTable();
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols("Monto Pagado ",0,1);
					pc.addCols(""+cdo1.getColValue("ingTot"),2,2);													
						pc.addCols("",1,1);
					pc.addCols("Impuesto sobre la Renta ",0,1);
					pc.addCols(""+cdo1.getColValue("impRen"),2,1);													
					pc.addCols("",1,1);
				pc.addTable();	
				
				
				pc.createTable();	
					pc.addCols("Gasto de Representacion ",0,1);
					pc.addCols(""+cdo1.getColValue("gasRep"),2,2);													
					pc.addCols("",1,1);
					pc.addCols("Seguro Social ",0,1);
					pc.addCols(""+cdo1.getColValue("segSoc"),2,1);												
					pc.addCols("",1,1);
				pc.addTable();	
				
				pc.createTable();	
					pc.addCols("Otros Ingresos",0,1);
					pc.addCols(""+cdo1.getColValue("otroIng"),2,2);													
					pc.addCols("",1,1);
					pc.addCols("Otros Egresos ",0,1);
					pc.addCols(""+cdo1.getColValue("otroEg"),2,1);													
					pc.addCols("",1,1);
				pc.addTable();	
				
				pc.createTable();	
					pc.addCols("Total de Ingresos ",2,1);
					pc.addCols(""+cdo1.getColValue("ingTot"),2,2);													
					pc.addCols("",1,1);
					pc.addCols("Total de Egresos ",2,1);
					pc.addCols(""+cdo1.getColValue("totDed"),2,1);													
					pc.addCols("",1,1);
				pc.addTable();	
				
				pc.createTable();	
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols("SALARIO NETO ",2,6);
					pc.addCols(""+cdo1.getColValue("salNeto"),1,1);													
				pc.addTable();	
				
				pc.createTable();	
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols(" ",0,1);
					pc.addCols("",2,1);													
					pc.addCols("  ",2,2);
					pc.addCols(" ",0,3);
				pc.addTable();	
				
				
				pc.createTable();	
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols(" ",2,7);
			 pc.addTable();	
			 
			 	pc.createTable();	
				pc.setFont("COURIER",9, 0, Color.black);
					pc.addCols("Nota : *** Metas Internacionales de Seguridad del Paciente ***",1,7);
			 pc.addTable();	
				
					pc.addNewPage();	
							if ((i + 1) == nItems) break;
						}//End For
						
						
						
						}//End If
						if((no+2)<=maxLines){
				}else{
					pc.addNewPage();
				}
				}
				
				
			}//End For
			


			
	pc.close();
				response.sendRedirect(redirectFile);
		
		}

%>



