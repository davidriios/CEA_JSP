<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Properties" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.Company"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />

<%
/** Check whether the user is logged in or not what access rights he has----------------------------
0	SISTEMA TODO        ACCESO TODO SISTEMA             A
---------------------------------------------------------------------------------------------------*/
SecMgr.setConnection(ConMgr);
if(!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
		UserDet=SecMgr.getUserDetails(session.getId());
		session.setAttribute("UserDet",UserDet);
		issi.admin.ISSILogger.setSession(session);

		CmnMgr.setConnection(ConMgr);
		SQLMgr.setConnection(ConMgr);


		SQL2BeanBuilder sbb = new SQL2BeanBuilder();
		CommonDataObject cdo = new CommonDataObject();

			String sql = "";
			String appendFilter = request.getParameter("appendFilter");
			String turno = request.getParameter("turno");
			String factura = request.getParameter("factura");
			String caja = request.getParameter("caja");
			String fechaini = request.getParameter("fechaini");
			String fechafin = request.getParameter("fechafin");
			String usuario = UserDet.getUserName();
			String compania =(String) session.getAttribute("_companyId");
			String codigo_rem = "";
			if(appendFilter== null)appendFilter="";
			String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
			ArrayList al   = new ArrayList();
			ArrayList al2  = new ArrayList();
	    	Company com= new Company();


		sql="select codigo as compCode, nombre as compLegalName,nvl( ruc,'') as compRUCNo, nvl(apartado_postal,'') as compPAddress, zona_postal as compAddress, nvl(telefono,'') as compTel1 from TBL_SEC_COMPANIA where codigo="+(String) session.getAttribute("_companyId");

com = (Company) sbb.getSingleRowBean(ConMgr.getConnection(),sql,Company.class);

sql="SELECT f.numero_factura,TO_CHAR(f.admi_fecha_nacimiento,'dd/mm/yyyy')AS fecha_nacimiento,  f.admi_codigo_paciente AS cod_paciente,f.admi_secuencia AS admision, f.usuario_creacion,f.tipo rem_tipo, f.codigo transa,f.compania,  f.anio,f.cod_empresa, DECODE(f.cod_empresa,109,'PACIENTE PARTICULAR',e.nombre) AS nombre_empresa,r.nombre AS responsable , 'E'   facturar_a, p.primer_apellido||' '||p.segundo_apellido||' '||p.apellido_de_casada||' '||p.primer_nombre||' '||p.segundo_nombre AS nombre_paciente,p.residencia_direccion,TO_CHAR(a.fecha_ingreso,'dd/mm/yyyy') AS fecha_ingreso,DECODE(p.telefono, NULL,' ',p.telefono,'Casa '||p.telefono )AS telefono, DECODE(p.telefono_trabajo_urgencia, NULL,' ',p.telefono_trabajo_urgencia,'/ trab '||p.telefono_trabajo_urgencia )AS telefono_trabajo FROM TBL_FAC_REMANENTE f,TBL_ADM_PACIENTE p ,TBL_ADM_EMPRESA e, TBL_ADM_RESPONSABLE r,TBL_ADM_ADMISION a WHERE f.numero_factura = '"+factura+"' AND f.compania= "+compania+" AND (f.tipo IN ('2')) AND f.cod_empresa = e.codigo(+) AND f.admi_fecha_nacimiento =p.fecha_nacimiento(+) AND f.admi_codigo_paciente = p.codigo(+) AND f.pac_id =r.pac_id(+) AND f.admi_secuencia = r.admision(+) and r.estado (+)='A'AND f.admi_fecha_nacimiento =a.fecha_nacimiento(+) AND f.admi_codigo_paciente = a.codigo_paciente(+) AND f.admi_secuencia = a.secuencia(+)";
	cdo  = SQLMgr.getData(sql);
if(cdo!= null)
	codigo_rem = cdo.getColValue("transa");
		
sql="SELECT f.numero_factura,TO_CHAR(f.admi_fecha_nacimiento,'dd/mm/yyyy')AS fecha,f.admi_codigo_paciente,f.admi_secuencia,f.tipo rem_tipo,f.codigo transa, fd.med_empresa,fd.medico,  fd.centro_servicio, DECODE(fd.tipo,'H',DECODE(fd.medico,NULL,fd.med_empresa,fd.medico,fd.medico),'E',DECODE(fd.med_empresa,NULL,fd.medico,fd.med_empresa,fd.med_empresa),'M',fd.centro_servicio,'C',fd.centro_servicio)AS codigo,fd.tipo,'E' AS facturar_a, DECODE(f.facturar_a,'O',a.descripcion,'P',DECODE(fd.tipo,'E',e.nombre,'H',m.primer_apellido||' '||m.segundo_apellido||' ' ||m.apellido_de_casada||' '||m.primer_nombre||' '||m.segundo_nombre,'C',c.descripcion,'M',DECODE(fd.centro_servicio , NULL, a.descripcion,fd.centro_servicio,c.descripcion),'P',a.descripcion))AS descripcion,NVL(DECODE(fd.tipo,'C',dw.total_debito,'H', DECODE(fd.medico, NULL,dz.total_debito,fd.medico,dy.total_debito),'E',dz.total_debito),0)AS total_debito,NVL(DECODE(fd.tipo,'C',DECODE(fd.centro_servicio,NULL,x.total_credito,fd.centro_servicio,w.total_credito),'H', DECODE(fd.medico, NULL,z.total_credito,fd.medico,y.total_credito),'E',z.total_credito),0)AS total_credito ,'' AS fecha_recibo,'0' AS recibo, 0 AS pagos,0 AS pago_aplicado FROM TBL_FAC_REMANENTE f,TBL_FAC_DET_REMANENTE fd , TBL_ADM_EMPRESA e,TBL_FAC_DETALLE_FACTURA a,TBL_ADM_MEDICO m ,TBL_CDS_CENTRO_SERVICIO c,(SELECT SUM(DECODE(r.tipo,'2',d.monto)) AS total_debito,d.centro_servicio AS centro FROM TBL_FAC_REMANENTE r, TBL_FAC_DET_REMANENTE d WHERE r.numero_factura = '"+factura+"' AND r.compania= "+compania+" AND (d.factura= r.numero_factura AND d.compania = r.compania)GROUP BY d.centro_servicio)dw,(SELECT NVL(SUM(NVL(d.monto,0)),0) AS total_credito,d.centro_servicio AS centro FROM TBL_FAC_REMANENTE r,TBL_FAC_DET_REMANENTE d WHERE  r.numero_factura   = '"+factura+"' AND r.compania="+compania+" AND r.tipo = '7'AND (d.factura = r.numero_factura AND  d.codigo = r.codigo AND  d.compania = r.compania /* se elimina amarre con el anio. solicitado: sra. lita 1-7-2003.-- and  d.anio= r.anio*/ AND  d.tipo= 'C') AND (d.medico IS NULL AND  d.med_empresa IS NULL) GROUP BY d.centro_servicio) w,(SELECT SUM(NVL(d.monto,0)) total_credito,d.centro_servicio AS centro,r.numero_factura AS factura FROM TBL_FAC_REMANENTE r, TBL_FAC_DET_REMANENTE d WHERE  r.numero_factura   = '"+factura+"' AND r.compania="+compania+" AND r.tipo= '7'AND (d.factura= r.numero_factura AND  d.codigo= r.codigo AND  d.compania= r.compania /*se elimina amarre con el anio. solicitado: sra. lita 1-7-2003.and  d.anio = r.anio*/ AND  d.tipo = 'c') AND (d.centro_servicio IS NULL AND  d.medico IS NULL AND  d.med_empresa IS NULL) GROUP BY d.centro_servicio,r.numero_factura ) x,(SELECT SUM(DECODE(r.tipo,'2',d.monto)) AS total_debito,d.medico FROM TBL_FAC_DET_REMANENTE d, TBL_FAC_REMANENTE r WHERE r.numero_factura = '"+factura+"' AND r.compania="+compania+" AND (d.factura= r.numero_factura AND d.compania= r.compania) GROUP BY d.medico )dy,(SELECT SUM(NVL(d.monto,0)) total_credito ,d.medico FROM TBL_FAC_DET_REMANENTE d, TBL_FAC_REMANENTE r WHERE (r.numero_factura = '"+factura+"'  AND r.compania= "+compania+" AND r.tipo= '7') AND (d.factura = r.numero_factura AND  d.codigo= r.codigo AND  d.compania= r.compania /*se elimina amarre con el anio. solicitado: sra. lita 1-7-2003. and  d.anio= r.anio*/ AND d.tipo = 'H') AND (d.med_empresa IS NULL AND d.centro_servicio IS NULL)GROUP BY d.medico)y,(SELECT SUM(DECODE(r.tipo,'2',d.monto)) AS total_debito,d.med_empresa FROM TBL_FAC_DET_REMANENTE d, TBL_FAC_REMANENTE r WHERE r.numero_factura = '"+factura+"' AND r.compania= "+compania+" AND (d.factura = r.numero_factura AND d.compania = r.compania) GROUP BY d.med_empresa )dz,(SELECT SUM(NVL(d.monto,0)) total_credito,d.med_empresa FROM TBL_FAC_DET_REMANENTE d, TBL_FAC_REMANENTE r WHERE (r.numero_factura = '"+factura+"' AND r.compania= "+compania+" AND  r.tipo= '7')AND (d.factura= r.numero_factura AND d.codigo= r.codigo AND d.compania = r.compania AND  d.tipo= 'E')AND (d.medico IS NULL AND  d.centro_servicio IS NULL) GROUP BY d.med_empresa)z WHERE f.numero_factura = '"+factura+"' AND f.compania= "+compania+" AND (fd.compania = f.compania  AND fd.factura = f.numero_factura  AND fd.codigo = f.codigo AND f.tipo IN ('2')) AND fd.med_empresa = e.codigo(+) AND a.fac_codigo(+)= '"+factura+"' AND a.compania="+compania+" AND fd.centro_servicio = c.codigo(+) AND fd.medico=m.codigo(+) AND  fd.centro_servicio=w.centro(+) AND f.numero_factura=x.factura(+) AND fd.medico=y.medico(+) AND fd.med_empresa=z.med_empresa(+)  AND fd.centro_servicio =dw.centro(+) AND fd.med_empresa = dz.med_empresa(+) AND fd.medico=dy.medico(+) GROUP BY  f.numero_factura,f.facturar_a, f.admi_fecha_nacimiento, f.admi_codigo_paciente, f.admi_secuencia, f.usuario_creacion, f.tipo,f.codigo,f.compania,f.anio,f.cod_empresa,fd.med_empresa, fd.medico,fd.centro_servicio,fd.tipo,DECODE(f.facturar_a,'O',a.descripcion,'P',DECODE(fd.tipo,'E',e.nombre,'H',m.primer_apellido||' '||m.segundo_apellido||' ' ||m.apellido_de_casada||' '||m.primer_nombre||' '||m.segundo_nombre,'C',c.descripcion,'M',DECODE(fd.centro_servicio , NULL, a.descripcion,fd.centro_servicio,c.descripcion),'P',a.descripcion)),DECODE(fd.tipo,'C',DECODE(fd.centro_servicio,NULL,x.total_credito,fd.centro_servicio,w.total_credito),'H', DECODE(fd.medico, NULL,z.total_credito,fd.medico,y.total_credito),'E',z.total_credito),NVL(DECODE(fd.tipo,'C',dw.total_debito,'H', DECODE(fd.medico, NULL,dz.total_debito,fd.medico,dy.total_debito),'E',dz.total_debito),0),DECODE(fd.tipo,'H',DECODE(fd.medico,NULL,fd.med_empresa,fd.medico,fd.medico),'E',DECODE(fd.med_empresa,NULL,fd.medico,fd.med_empresa,fd.med_empresa),'M',fd.centro_servicio,'C',fd.centro_servicio)UNION SELECT rm.numero_factura AS factura,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'R' AS tipo,'E',' ',0,0, TO_CHAR(cdp.fecha_creacion,'dd/mm/yyyy')AS fecha_recibo, cr.codigo recibo,ctp.pago_total pagos, SUM(NVL(cdp.monto,0)) pago_aplicado FROM TBL_CJA_TRANSACCION_PAGO ctp,TBL_CJA_DETALLE_PAGO cdp,TBL_CJA_RECIBOS cr, TBL_FAC_REMANENTE rm WHERE ctp.CODIGO = cdp.CODIGO_TRANSACCION AND rm.compania="+compania+" AND rm.NUMERO_FACTURA = '"+factura+"' AND ctp.compania = cdp.compania AND ctp.anio = cdp.tran_anio AND ctp.codigo = cr.CTP_CODIGO AND ctp.ANIO = cr.CTP_ANIO AND ctp.COMPANIA = cr.compania AND cdp.COD_REM  = rm.CODIGO AND cdp.compania = rm.compania GROUP BY  rm.numero_factura,cdp.fecha_creacion, cdp.FAC_CODIGO,cr.codigo, ctp.pago_total ORDER BY 17 ASC ";
	al = SQLMgr.getDataList(sql);
	

	if(request.getMethod().equalsIgnoreCase("GET")) {
		String banco2 ="";
		double monto_pago =0.00;//abonos
		double monto_debito =0.00;
		double monto_credito =0.00 ;
		double monto_saldo =0.00;
		double monto_descuento =0.00;
		double monto_aplicado =0.00;

		int recibos = 0 ;
		int maxLines = 30; //max lines of items
		int nItems = al.size(); //number of items
		int extraItems = nItems % maxLines;
		int nPages = 0;	//number of pages
		int lineFill = 0; //empty lines to be fill
		//calculating number of page
		if (extraItems == 0) nPages = (nItems / maxLines);
		else nPages = (nItems / maxLines) + 1;
		if (nPages == 0) nPages = 1;

		String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	    String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
		String statusPath = "";
		boolean logoMark = true;
		boolean statusMark = false;

		String folderName = "cxc";
		String fileNamePrefix = "print_ajuste_factura";
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
		String fileName=fileNamePrefix+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+"_"+CmnMgr.getCurrentDate("ddmmyyyyhh12missam")+".pdf";
		String create = CmnMgr.createFolder(directory, folderName, year, month);

		if(create.equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
		else
		{
			String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;
			fileName=directory+folderName+"/"+year+"/"+month+"/"+fileName;

			int headerFooterFont = 4;

			StringBuffer sbFooter = new StringBuffer();

			float leftRightMargin = 9.0f;
			float topMargin = 13.5f;
			float bottomMargin = 9.0f;

			issi.admin.PdfCreator pc = new issi.admin.PdfCreator(fileName, 612, 792, false, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath);


int no2 = 0;
				Vector setValD=new Vector();

					setValD.addElement(".10");
					setValD.addElement(".30");
					setValD.addElement(".12");
					setValD.addElement(".12");
					setValD.addElement(".12");
					setValD.addElement(".12");
					setValD.addElement(".12");


			for (int j=1; j<=nPages; j++)
			{
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
					pc.addCols("CXC",1,2);
					pc.addTable();

				pc.createTable();
					pc.setFont(9, 1);
					pc.addCols("NOTA DE DÉBITO",1,2);
					pc.addTable();


				Vector setHeader01=new Vector();
				   setHeader01.addElement(".5");
				   setHeader01.addElement(".5");

				pc.setNoColumnFixWidth(setHeader01);
				pc.createTable();
			        pc.setFont(7, 1);
			        pc.addCols("Usuario: "+usuario,0,1);
					pc.addCols("Reporte: 	CXC90074", 2, 1);
				pc.addTable();
				pc.setNoColumnFixWidth(setHeader01);
				pc.createTable();
				pc.setFont(7, 1);
					pc.addCols("Fecha :  "+fecha, 0, 1);
					pc.addCols("Página: "+j+" de "+nPages, 2, 1);
			   	pc.addTable();


				Vector setHeader2=new Vector();
					setHeader2.addElement(".20");
					setHeader2.addElement(".30");
					setHeader2.addElement(".20");
					setHeader2.addElement(".30");
				pc.setNoColumnFixWidth(setHeader2);


				pc.createTable();
					pc.setFont(7, 1);
					pc.addCols("", 0,4);
				pc.addTable();
             
			 if (cdo != null){

				pc.createTable();
					pc.addCols("Nota Debito",0,1);
					pc.addCols(""+cdo.getColValue("transa"),0,3);
				pc.addTable();
				pc.createTable();
					pc.addCols("Factura",0,1);
					pc.addCols(""+factura,0,3);
				pc.addTable();
				pc.createTable();
					pc.addCols("Paciente",0,1);
					pc.addCols(""+cdo.getColValue("nombre_paciente"),0,1);
					pc.addCols("No Admision",0,1);
					pc.addCols(""+cdo.getColValue("admision")+"               codigo:"+cdo.getColValue("cod_paciente"),0,1);
				pc.addTable();
				pc.createTable();
					pc.addCols("Fecha Nacimiento",0,1);
					pc.addCols(""+cdo.getColValue("fecha_nacimiento"),0,1);
					pc.addCols("Fecha Ingreso ",0,1);
					pc.addCols(""+cdo.getColValue("fecha_ingreso"),0,1);
				pc.addTable();
				pc.createTable();
					pc.addCols("Direccion",0,1);
					pc.addCols(""+cdo.getColValue("residencia_direccion"),0,1);
					pc.addCols("Telefono ",0,1);
					pc.addCols(""+cdo.getColValue("telefono")+" "+cdo.getColValue("telefono_trabajo"),0,1);
				pc.addTable();
				pc.createTable();
					pc.addCols("Empresa",0,1);
					pc.addCols(""+cdo.getColValue("nombre_empresa"),0,3);
				pc.addTable();
				pc.createTable();
					pc.addCols("Responsable",0,1);
					pc.addCols(""+cdo.getColValue("responsable"),0,3);
				pc.addTable();

				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
					pc.setFont(8, 1);
					pc.addBorderCols("Código",0);
					pc.addBorderCols("Descripcion",0);
					pc.addBorderCols("Débitos",1);
					pc.addBorderCols("Pagos",1);
					pc.addBorderCols("Créditos",1);
					pc.addBorderCols("Descuento",1);
					pc.addBorderCols("Saldos",1);
				pc.addTable();
		} //if cdo is not null

				if(al.size()==0)
				{
					pc.createTable();
						pc.setFont(9, 1);
						pc.addCols("No Existe ajuste a está factura.",1,7);
					pc.addTable();

				}//End If
				else{
					if (al.size() > 0)
					{
						for (int x=0; x<al.size(); x++)
						{
						    CommonDataObject cdo1 = (CommonDataObject) al.get(x);
							if(cdo1.getColValue("tipo").trim().equals("R"))
							{
								monto_pago += Double.parseDouble(cdo1.getColValue("pagos"));
								monto_aplicado += Double.parseDouble(cdo1.getColValue("pago_aplicado"));
							}

						}
						for (int i=((maxLines * j) - maxLines); i<(maxLines * j); i++)
						{
						    CommonDataObject cdo1 = (CommonDataObject) al.get(i);


								no2 += 1;
								if(!cdo1.getColValue("tipo").trim().equals("R"))
								{
								pc.createTable();
								pc.setFont(7, 0);
									pc.addCols(" "+cdo1.getColValue("codigo"),0,1);
									pc.addCols(" "+cdo1.getColValue("descripcion"),0,1);
									pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("total_debito")),2,1);
									pc.addCols(" ",2,1);
									pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("total_credito")),2,1);
									pc.addCols(" ",0,1);
									pc.addCols(" ",0,1);
								pc.addTable();


								monto_debito += Double.parseDouble(cdo1.getColValue("total_debito"));
								monto_credito += Double.parseDouble(cdo1.getColValue("total_credito"));

								}
								else if(cdo1.getColValue("tipo").trim().equals("R") )
								{
									if(recibos==0)
									{
										monto_saldo += monto_debito-monto_credito-monto_descuento-monto_pago;
										pc.setNoColumnFixWidth(setValD);
										pc.createTable();
										pc.setFont(7, 1);
										pc.addCols(" ", 0, 7);
										pc.addTable();

										pc.setNoColumnFixWidth(setValD);
										pc.createTable();
										pc.setFont(8, 1);
										pc.addCols("Totales:", 2, 2);
										pc.addCols(""+CmnMgr.getFormattedDecimal(monto_debito), 2, 1);
										pc.addCols(""+CmnMgr.getFormattedDecimal(monto_pago), 2, 1);
										pc.addCols(""+CmnMgr.getFormattedDecimal(monto_credito), 2, 1);
										pc.addCols(""+CmnMgr.getFormattedDecimal(monto_descuento), 2, 1);
										pc.addCols(""+CmnMgr.getFormattedDecimal(monto_saldo), 2, 1);
										pc.addTable();
										pc.createTable();
										pc.setFont(7, 1);
										pc.addCols(" ", 0, 7);
										pc.addTable();
										pc.setNoColumnFixWidth(setValD);
										pc.createTable();
											pc.setFont(8, 1);
											pc.addCols("Fecha del Recibo", 0, 1);
											pc.addCols(" ", 2, 1);
											pc.addCols("No. de Recibo", 0, 1);
											pc.addCols("Total Pagado por recibos ", 2, 1);
											pc.addCols("", 2, 1);
											pc.addCols("Monto Aplicado O distribuido ", 2, 1);
											pc.addCols("", 2, 1);
										pc.addTable();
									}

									pc.setNoColumnFixWidth(setValD);
									pc.createTable();
										pc.setFont(7, 0);
										pc.addCols(""+cdo1.getColValue("fecha_recibo"), 0, 1);
										pc.addCols(" ", 2, 1);
										pc.addCols(""+cdo1.getColValue("recibo"), 0, 1);
										pc.addCols(""+CmnMgr.getFormattedDecimal(cdo1.getColValue("pagos")), 2, 1);
										pc.addCols("", 2, 1);
										pc.addCols(" "+CmnMgr.getFormattedDecimal(cdo1.getColValue("pago_aplicado")), 2, 1);
										pc.addCols("", 2, 1);
									pc.addTable();
									recibos++;
								}

								if ((i + 1) == nItems) 	break;
						}//End For
						}//End If
						if((no2+2)<=maxLines){
				}else{
					pc.addNewPage();
				}
				}

			}//End For
			if(recibos==0)
			{
				monto_saldo += monto_debito-monto_credito-monto_descuento-monto_pago;
				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
				pc.setFont(7, 1);
				pc.addCols(" ", 0, 7);
				pc.addTable();

				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
				pc.setFont(8, 1);
				pc.addCols("Totales:", 2, 2);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_debito), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_pago), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_credito), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_descuento), 2, 1);
				pc.addCols(""+CmnMgr.getFormattedDecimal(monto_saldo), 2, 1);
				pc.addTable();
				pc.createTable();
				pc.setFont(7, 1);
				pc.addCols(" ", 0, 7);
				pc.addTable();
				pc.setNoColumnFixWidth(setValD);
				pc.createTable();
					pc.setFont(8, 1);
					pc.addCols("Fecha del Recibo", 0, 1);
					pc.addCols(" ", 2, 1);
					pc.addCols("No. de Recibo", 0, 1);
					pc.addCols("Total Pagado por recibos ", 2, 1);
					pc.addCols("", 2, 1);
					pc.addCols("Monto Aplicado O distribuido ", 2, 1);
					pc.addCols("", 2, 1);
				pc.addTable();
			}


			pc.setNoColumnFixWidth(setValD);
			pc.createTable();
			pc.setFont(8, 1);
			pc.addCols("Totales:", 2, 2);
			pc.addCols("--------->", 2, 1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto_pago), 2, 1);
			pc.addCols("", 2, 1);
			pc.addCols(""+CmnMgr.getFormattedDecimal(monto_aplicado), 2, 1);
			pc.addCols("", 2, 1);
			pc.addTable();

	pc.close();
				response.sendRedirect(redirectFile);
		}
		}

%>





