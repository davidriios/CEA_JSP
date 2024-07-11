<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.awt.Color" %>
<%@ page import="issi.admin.PdfCreator" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<!-- Desarrollado por: Tirza Monteza     -->
<!-- Reporte: Estadistica Urgencias - Completa    -->
<!-- Reporte: fac71013                   -->
<!-- Clínica Hospital San Fernando       -->
<!-- Fecha: 03/08/2010                   -->

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");/*quitar el comentario * */

UserDet = SecMgr.getUserDetails(session.getId()); /*quitar el comentario * */
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo0 = new CommonDataObject();

ArrayList al0 = new ArrayList();
ArrayList al1 = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList al4 = new ArrayList();
ArrayList al5 = new ArrayList();
ArrayList al6 = new ArrayList();

String sql = "";
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();  /*quitar el comentario * */

String compania = (String) session.getAttribute("_companyId");
String fechaini        = request.getParameter("fechaini");
String fechafin        = request.getParameter("fechafin");

if (fechaini == null) fechaini = "";
if (fechafin == null) fechafin = "";
if (appendFilter == null) appendFilter = "";

String appendFilter1 = "";

//-------------------------------------------------------------------------------------------------------//
//--------------Query para obtener datos ---------------------------------//

// total de casos atendidos
sql = "select s.ord, s.descripcion, s.cantidad from ( select 1 ord, 'TOTAL DE CASOS ATENDIDOS' descripcion, count(*) cantidad from temp_urg_estadist union select 2 ord, 'Total de Consultas' descripcion,  sum(decode(ft.tipo_transaccion, 'C',nvl(dt.cantidad,0),'D',-(nvl(dt.cantidad,0)))) total from tbl_fac_detalle_transaccion dt, tbl_cds_tipo_servicio cds, tbl_fac_transaccion ft, temp_urg_estadist t where t.fecha_nacimiento = ft.admi_fecha_nacimiento  and  t.codigo_paciente   = ft.admi_codigo_paciente  and  t.secuencia   = ft.admi_secuencia  and dt.tipo_transaccion   =ft.tipo_transaccion  and dt.compania   = ft.compania  and dt.fac_codigo_paciente =ft.admi_codigo_paciente  and dt.fac_fecha_nacimiento  =  ft.admi_fecha_nacimiento  and dt.fac_secuencia       = ft.admi_secuencia  and dt.fac_codigo  = ft.codigo  and dt.compania   = 1  and  dt.cod_uso  = 260  and  dt.tipo_cargo = cds.codigo  and  dt.cantidad   > 0) s  order by s.ord ";
al0 = SQLMgr.getDataList(sql);

// hospitalizaciones en chsf
sql = "select c.ord, c.descripcion, c.cantidad  from ( select 1 ord, 'HOSPITALIZACIONES EN C.H.S.F' descripcion, count(*) cantidad  from   tbl_adm_admision  where (fecha_ingreso >= TO_DATE('"+fechaini+"','DD-MM-YYYY') and   fecha_ingreso <= TO_DATE('"+fechafin+"','DD-MM-YYYY') ) and   estado     NOT IN ('N') and   categoria      IN (1,5) and   NOT (secuencia = NVL(corte_cta,0) + 1 AND   corte_cta >= 1) union  select  2 ord, 'Vía Cuarto de Urgencias',  count(*)  from   tbl_adm_admision  where (fecha_ingreso  >= TO_DATE('"+fechaini+"','DD-MM-YYYY') and   fecha_ingreso  <= TO_DATE('"+fechafin+"','DD-MM-YYYY') )  and   centro_servicio = 10 and   categoria      IN (1)  /*(1,5)  No incluye Hospitalizado Directo  */  and   estado     NOT IN ('N') and   NOT (secuencia = NVL(corte_cta,0) + 1   AND   corte_cta >= 1) ) c  order by c.ord ";
al1 = SQLMgr.getDataList(sql);

// distribucion por sexo
sql = "select decode(p.sexo,'F','Femenino', 'M','Masculino','No Especificados') sexo,  count(*) cantidad from temp_urg_estadist t, adm_paciente p  where (t.fecha_nacimiento = p.fecha_nacimiento and t.codigo_paciente   = p.codigo) group by decode(p.sexo,'F','Femenino', 'M','Masculino','No Especificados') order by 1";
al2 = SQLMgr.getDataList(sql);

// distribucion por edad
sql = "select tipo, count(*) cantidad from (select  case when ((TRUNC(SYSDATE - t.fecha_nacimiento) / 365) >= 18) then 'Pacientes Adultos' else 'Menores de 18 años' end tipo from temp_urg_estadist t,  adm_paciente p  where p.fecha_nacimiento = t.fecha_nacimiento  and  p.codigo   = t.codigo_paciente) e group by e.tipo";
al3 = SQLMgr.getDataList(sql);

// distribucion por aseg, provincia, distrito, corregimiento
sql = "select d.ord, d.tipoGrupo, d.descripcion, d.cantidad from (select 1 ord, 'DISTRIBUCION POR ASEGURADORAS' tipoGrupo, nvl(e.nombre,'SIN ESPECIFICAR') descripcion, count(*) cantidad  from  TEMP_URG_ESTADIST t, tbl_adm_empresa e where t.aseguradora = e.codigo  group by  t.aseguradora, e.nombre union  select 2 ord,  'DISTRIBUCION POR PROVINCIA' tipoGrupo, nvl(pro.nombre,'SIN ESPECIFICAR') descripcion,  count(*) cantidad  FROM  tbl_adm_paciente  p,  temp_urg_estadist t, sfplanilla.provincia  pro WHERE t.fecha_nacimiento = p.fecha_nacimiento  and  t.codigo_paciente   = p.codigo and p.residencia_pais   = pro.pais(+)  and  p.residencia_provincia  = pro.codigo(+) group by pro.codigo, pro.nombre  union   select 3 ord, 'DISTRIBUCION POR DISTRITO' tipoGrupo, nvl(dis.nombre,'SIN ESPECIFICAR') descripcion,  count(*) cantidad  from  tbl_adm_paciente  p, temp_urg_estadist t,  sfplanilla.distrito dis  where t.fecha_nacimiento = p.fecha_nacimiento  and t.codigo_paciente   = p.codigo  and p.residencia_pais   = dis.pais(+)  and  p.residencia_provincia  =  dis.provincia(+) and  p.residencia_distrito  = dis.codigo(+)  group by dis.nombre   union    select  4 ord, 'DISTRIBUCION POR CORREGIMIENTO' tipoGrupo, nvl(co.nombre,'SIN ESPECIFICAR') descripcion,  count(*) cantidad  from   tbl_adm_paciente  p,  temp_urg_estadist t,  sfplanilla.corregimiento co  where t.fecha_nacimiento = p.fecha_nacimiento  and t.codigo_paciente = p.codigo  and p.residencia_pais         = co.pais(+)  and  p.residencia_provincia = co.provincia(+)  and  p.residencia_distrito  = co.distrito(+)   and  p.residencia_corregimiento = co.codigo(+)  and  co.provincia = '8'  and  co.distrito  in (8,10) group by co.nombre) d  order by d.ord asc, d.cantidad desc ";
al4 = SQLMgr.getDataList(sql);

// analisis economico
sql = "select e.ord, e.tipo, nvl(e.monto,0) monto, nvl(e.cantidad,0) cantidad from (select 1 ord, 'AMBULANCIA' tipo, sum(a.monto_ambulancia) monto,  sum(a.cantidad) cantidad from (select sum(decode(d.tipo_transaccion, 'C',(nvl(d.cantidad,0)*nvl(d.monto,0)), 'D',-(nvl(d.cantidad,0)*nvl(d.monto,0))))  monto_ambulancia,  decode  (d.tipo_transaccion,'C',nvl(d.cantidad,0),'D',-nvl(d.cantidad,0)) cantidad,  d.fac_fecha_nacimiento,d.fac_codigo_paciente, d.fac_secuencia,  d.fecha_cargo fe_cargo,  d.fecha_creacion fe_crea, adm.fecha_ingreso adm_ingre, p.primer_nombre||' '||p.segundo_nombre||' '||(decode(p.apellido_de_casada,null,p.primer_apellido||' '||p.segundo_apellido, p.apellido_de_casada||' '||p.primer_apellido||' '||p.segundo_apellido) )  nombre_paciente , decode(adm.categoria,1,'HOSP',2,'AMB',3,'ESP',4,'GER') tipo_admi , d.usuario_creacion , d.tipo_transaccion  , d.centro_servicio  from tbl_fac_detalle_transaccion d, tbl_cds_tipo_servicio, tbl_fac_transaccion, tbl_adm_admision adm, vw_adm_paciente p /* La licda. Sara Barés solicitó que se busque por Fecha de Registro del Cargo. 9/7/2004.  ANGEL */ where (d.fecha_creacion >= to_date('"+fechaini+"','DD-MM-YYYY')  and      d.fecha_creacion <= to_date('"+fechafin+"','DD-MM-YYYY') )  and   adm.estado not in ('N')  and ((d.tipo_cargo  = cds_tipo_servicio.codigo)  and  (d.tipo_transaccion   = fac_transaccion.tipo_transaccion  and   d.compania  = fac_transaccion.compania  and d.fac_codigo_paciente    = fac_transaccion.admi_codigo_paciente  and d.fac_fecha_nacimiento   = fac_transaccion.admi_fecha_nacimiento  and d.fac_secuencia   = fac_transaccion.admi_secuencia   and d.fac_codigo   = fac_transaccion.codigo))    and d.tipo_cargo  = '06'  and (adm.fecha_nacimiento = fac_transaccion.admi_fecha_nacimiento   and  adm.codigo_paciente  = fac_transaccion.admi_codigo_paciente   and  adm.secuencia   = fac_transaccion.admi_secuencia)  and (p.fecha_nacimiento = adm.fecha_nacimiento  and  p.codigo  = adm.codigo_paciente)  and d.centro_servicio not in (901)  /* Excluye Ambulancias Externas */  group by p.primer_nombre||' '||p.segundo_nombre||' '||(decode(p.apellido_de_casada,null,p.primer_apellido||' '||p.segundo_apellido,p.apellido_de_casada||' '||p.primer_apellido||' '||p.segundo_apellido) ) , d.fac_fecha_nacimiento,d.fac_codigo_paciente, d.fac_secuencia, d.fecha_creacion,d.tipo_transaccion, d.fecha_cargo, d.usuario_creacion, adm.fecha_ingreso,decode(adm.categoria,1,'HOSP',2,'AMB',3,'ESP',4,'GER'), d.centro_servicio, decode  (d.tipo_transaccion,'C',nvl(d.cantidad,0),'D',-nvl(d.cantidad,0)) order by nombre_paciente) a union  select 2 ord, 'CORTESIAS EMPLEADO' tipo, sum(decode(d.tipo_transaccion,'C', (nvl(d.cantidad,0)*nvl(d.monto,0)), 'H', (nvl(d.cantidad,0)*nvl(d.monto,0)), 'D',-(nvl(d.cantidad,0)*nvl(d.monto,0)))) monto, 0 from  temp_urg_estadist e,  tbl_fac_detalle_transaccion d where e.fecha_nacimiento = d.fac_fecha_nacimiento and e.codigo_paciente   = d.fac_codigo_paciente  and e.secuencia  = d.fac_secuencia  and e.aseguradora   = 81  union  select 3 ord, 'SOLICITUD DE EMPLEO' tipo, sum(decode(dt.tipo_transaccion,'C',nvl(dt.cantidad,0)*nvl(dt.monto,0),'D',-(nvl(dt.cantidad,0)*nvl(dt.monto,0)) )) monto, sum(decode(dt.tipo_transaccion,'C',1,'D',0)) contador  from tbl_fac_detalle_transaccion dt, tbl_adm_admision a where (a.fecha_ingreso   >= to_date('"+fechaini+"','DD-MM-YYYY') and   a.fecha_ingreso   <=  to_date('"+fechafin+"','DD-MM-YYYY')  ) and  ( a.fecha_nacimiento = '31-01-2001' and   a.codigo_paciente  = 5 and   a.estado not in 'N') and a.codigo_paciente  = dt.fac_codigo_paciente and  a.fecha_nacimiento = dt.fac_fecha_nacimiento and  a.secuencia  = dt.fac_secuencia and dt.cod_uso    = 260  and  dt.compania   = 1 and  dt.cantidad   > 0 ) e  order by e.ord";
al5 = SQLMgr.getDataList(sql);

// cantidad de pacientes x centro y tipo de adm.
sql = "select c.centro_servicio, c.descripcion, sum(adultos) cantidad_adultos, sum(menores) cantidad_menores, count(*) total  from ( select a.fecha_nacimiento, a.codigo_paciente, a.secuencia, a.tipo_admision cod_tipo, t.descripcion, d.descripcion centro_servicio, case when ((TRUNC(SYSDATE - u.fecha_nacimiento) / 365) >= 18) then 1 else 0 end as adultos,  case when ((TRUNC(SYSDATE - u.fecha_nacimiento) / 365) >= 18) then 0 else 1 end as menores  from tbl_temp_urg_estadist u, tbl_adm_admision a, tbl_adm_tipo_admision_cia t, tbl_cds_centro_servicio d  where  a.fecha_nacimiento = u.fecha_nacimiento   and  a.codigo_paciente  = u.codigo_paciente   and  a.secuencia  = u.secuencia    and  a.compania = 1    and  a.categoria  = t.categoria   and  a.tipo_admision    = t.codigo   and  a.compania  = t.compania   and  a.centro_servicio  = d.codigo ) c   group by c.centro_servicio, c.descripcion order by 1,2";
al6 = SQLMgr.getDataList(sql);


if (request.getMethod().equalsIgnoreCase("GET"))
{
	 String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
//java.util.GregorianCalendar gc=new java.util.GregorianCalendar();
	String year=fecha.substring(6, 10);
	String mon=fecha.substring(3, 5);
	String month = null;
	String day=fecha.substring(0, 2);
	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+mon+"-"+day+"_"+UserDet.getUserId()+".pdf";

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

  String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = java.util.ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));

    if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile="../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "ADMISION";
	String subtitle = "CUARTO DE URGENCIAS - ESTADISTICA MENSUAL";
	String xtraSubtitle = "DESDE "+fechaini+"  HASTA  "+fechafin;

	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	int fontSize = 8;
	float cHeight = 12.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".15"); //
		dHeader.addElement(".50");
		dHeader.addElement(".10");
		dHeader.addElement(".10");
		dHeader.addElement(".15"); //

	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
	pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	pc.setTableHeader(1);

	pc.addBorderCols(" ",0,dHeader.size(),1.5f,0.0f,0.0f,0.0f);

	pc.addCols(" ",0,dHeader.size());

	//==========================================================================
	// seccion de CASOS ATENDIDOS
	int vTotal	= 0;
	for (int i=0; i<al0.size(); i++)
	{
      cdo0= (CommonDataObject) al0.get(i);

	    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
		  if (i == 0)
		  {
				pc.setFont(8, 1);
		    pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols(cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
		    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
		    pc.addCols(" ",0,2);																// espacios en blanco
				vTotal	+= Integer.parseInt(cdo0.getColValue("cantidad"));
		   } else
		   {
				pc.setFont(8, 0);
		    pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols("     "+cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
		    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
		    pc.addCols(" ",0,2);																// espacios en blanco
				vTotal	-= Integer.parseInt(cdo0.getColValue("cantidad"));
			 }
	}

	if (al0.size() !=0 )
	{
		pc.setFont(8, 0);
		pc.addCols(" ",0,1);    // en blanco 1ra col
    pc.addCols("     "+"Otros Servicios",0,1);    // descripcion del renglon
    pc.addCols(String.valueOf(vTotal),1,1);				// cantidad
    pc.addCols(" ",0,2);																// espacios en blanco
	}

	//==========================================================================
	// seccion de HOSPITALIZADOS
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	vTotal	= 0;
	for (int i=0; i<al1.size(); i++)
	{
      cdo0 = (CommonDataObject) al1.get(i);

	    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
		  if (i == 0)
		  {
				pc.setFont(8, 1);
		    pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols(cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
		    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
		    pc.addCols(" ",0,2);																// espacios en blanco
				vTotal	+= Integer.parseInt(cdo0.getColValue("cantidad"));
		   } else
		   {
				pc.setFont(8, 0);
		    pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols("     "+cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
		    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
		    pc.addCols(" ",0,2);																// espacios en blanco
				vTotal	-= Integer.parseInt(cdo0.getColValue("cantidad"));
			 }
	}

	if (al1.size() !=0 )
	{
		pc.setFont(8, 0);
    pc.addCols(" ",0,1);    // en blanco 1ra col
    pc.addCols("     "+"Otros Admisiones (Pediátrico, SOP, R.N.)",0,1);    // descripcion del renglon
    pc.addCols(String.valueOf(vTotal),1,1);				// cantidad
    pc.addCols(" ",0,2);																// espacios en blanco
	}


	//==========================================================================
	// seccion de DISTRIBUCION DE CASOS ATENDIDOS X SEXO
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	for (int i=0; i<al2.size(); i++)
	{
      cdo0 = (CommonDataObject) al2.get(i);

	    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
		  if (i == 0)
		  {
				pc.setFont(8, 1);
				pc.addCols(" ",0,1);    // en blanco 1ra col
				pc.addCols("DISTRIBUCION POR SEXO DE CASOS ATENDIDOS",0,4);    // titulo de la seccion
		  }
			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("sexo"),0,1);    				// descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco
	}


	//==========================================================================
	// seccion de DISTRIBUCION DE CASOS ATENDIDOS X EDAD
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	for (int i=0; i<al3.size(); i++)
	{
      cdo0 = (CommonDataObject) al3.get(i);

	    //Inicio -->> imprime el titulo para el grupo
		  if (i == 0)
		  {
				pc.setFont(8, 1);
				pc.addCols(" ",0,1);    // en blanco 1ra col
				pc.addCols("DISTRIBUCION POR EDAD DE CASOS ATENDIDOS",0,4);    // titulo de la seccion
		   }
			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("tipo"),0,1);    // descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco
	}


	//==========================================================================
	// seccion de DISTRIBUCION DE CASOS ATENDIDOS X ASEG, PROVINCIA, DISTRITO, CORREG.
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	String groupBy = "";
	for (int i=0; i<al4.size(); i++)
	{
      cdo0 = (CommonDataObject) al4.get(i);

			if(!groupBy.equalsIgnoreCase(cdo0.getColValue("tipoGrupo")))
			    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
			{
					pc.setFont(8, 1);
					pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
					pc.addCols(" ",0,1);    // en blanco 1ra col
					pc.addCols(cdo0.getColValue("tipoGrupo"),0,4);    // titulo de la seccion
			}
			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad"),1,1);				// cantidad
	    pc.addCols(" ",0,2);																// espacios en blanco

	    groupBy = cdo0.getColValue("tipoGrupo");
	}


	//==========================================================================
	// seccion de ANALISIS ECONOMICO
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	for (int i=0; i<al5.size(); i++)
	{
      cdo0 = (CommonDataObject) al5.get(i);

			if (i == 0)
			{
				pc.setFont(8, 1);
				pc.addCols(" ",0,1);    // en blanco 1ra col
				pc.addCols("ANALISIS ECONOMICO",0,4);    // titulo de la seccion
			}

			if (cdo0.getColValue("ord").equals("1"))   // ambulancias -> imprimir una linea para el monto y otra para la cantidad
			{
				pc.setFont(8, 0);
		    pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols("     Monto por cargos de ambulancia",0,1);    // descripcion del renglon
		    pc.addCols("B/. "+cdo0.getColValue("monto"),1,1);					 // monto
		    pc.addCols(" ",0,2);																 // espacios en blanco

		   	pc.addCols(" ",0,1);    // en blanco 1ra col
		   	pc.addCols("     Cantidad de viajes",0,1);   						 // descripcion del renglon
		    pc.addCols(cdo0.getColValue("cantidad"),1,1);				   // cantidad
		    pc.addCols(" ",0,2);																 // espacios en blanco
			}
			else if (cdo0.getColValue("ord").equals("3"))   // sol. empleo -> imprimir una linea para el monto y otra para la cantidad
			{
				pc.addCols(" ",0,dHeader.size());
				pc.setFont(8, 0);
				pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols("     Monto consultas Solicitud de empleo",0,1);    // descripcion del renglon
		    pc.addCols("B/. "+cdo0.getColValue("monto"),1,1);					 // monto
		    pc.addCols(" ",0,2);																 // espacios en blanco

		   	pc.addCols(" ",0,1);    // en blanco 1ra col
		   	pc.addCols("     Total consultas Sol. de Empleo",0,1);   						 // descripcion del renglon
		    pc.addCols(cdo0.getColValue("cantidad"),1,1);				   // cantidad
		    pc.addCols(" ",0,2);																 // espacios en blanco
			} else
			{
				pc.addCols(" ",0,dHeader.size());
				pc.setFont(8, 0);
				pc.addCols(" ",0,1);    // en blanco 1ra col
		    pc.addCols("     Monto por cortesías (Empleado)",0,1);    // descripcion del renglon
		    pc.addCols("B/. "+cdo0.getColValue("monto"),1,1);					 // monto
		    pc.addCols(" ",0,2);																 // espacios en blanco
			}
	}


	//==========================================================================
	// seccion de PACIENTES POR TIPO DE ATENC.
	pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
	vTotal	= 0;
	groupBy = "";
	for (int i=0; i<al6.size(); i++)
	{
      cdo0 = (CommonDataObject) al6.get(i);

			if(!groupBy.equalsIgnoreCase(cdo0.getColValue("centro_servicio")))
			    //Inicio -->> imprime el titulo y asigna el valor toal a vTotal para en el segundo registro restar y sacar el valor q va en el 3er renglon
			{
				if (i==0)
				{
					pc.setFont(8, 1);
					pc.addCols(" ",0,1);    // en blanco 1ra col
					pc.addCols("PACIENTES POR TIPO DE ADMISION",1,4);    // titulo de la seccion
					// titulos
					pc.setFont(8, 0);
					pc.addCols(" ",0,1);    // en blanco 1ra col
					pc.addBorderCols("Tipo de Admisión",1,1,0.5f,0.5f,0.0f,0.0f);    // titulo de la seccion
					pc.addBorderCols("Adultos",1,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("Menores",1,1,0.5f,0.5f,0.0f,0.0f);
					pc.addBorderCols("Total",1,1,0.5f,0.5f,0.0f,0.0f);
				}

				if (i!=0)
				{
					pc.setFont(8, 1);
					pc.addCols(" ",0,1);    // en blanco 1ra col
					pc.addCols("Total por Centro . . . ",2,3);    // titulo de la seccion
					pc.addCols(String.valueOf(vTotal),1,1);				// cantidad
				}

				pc.setFont(8, 1);
				pc.addCols(" ",1,dHeader.size());    // linea de separacio entre grupos
				pc.addCols(" ",0,1);    // en blanco 1ra col
				pc.addCols(cdo0.getColValue("centro_servicio"),0,4);    // titulo de la seccion
				vTotal	= 0;
			}

			pc.setFont(8, 0);
			pc.addCols(" ",0,1);    // en blanco 1ra col
	    pc.addCols("     "+cdo0.getColValue("descripcion"),0,1);    // descripcion del renglon
	    pc.addCols(cdo0.getColValue("cantidad_adultos"),1,1);				// cantidad
	    pc.addCols(cdo0.getColValue("cantidad_menores"),1,1);				// cantidad
	    pc.addCols(cdo0.getColValue("total"),1,1);				// cantidad

			vTotal	+= Integer.parseInt(cdo0.getColValue("total"));

	    groupBy = cdo0.getColValue("centro_servicio");
	}

	if (al6.size() > 0)
	{
		pc.setFont(8, 1);
		pc.addCols(" ",0,1);    // en blanco 1ra col
		pc.addCols("Total por Centro . . . ",2,3);    // titulo de la seccion
		pc.addCols(String.valueOf(vTotal),1,1);				// cantidad
	}

	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//get
%>
