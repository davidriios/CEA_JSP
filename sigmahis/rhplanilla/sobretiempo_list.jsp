<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.io.File"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
sct0100s
==================================================================================
**/
	SecMgr.setConnection(ConMgr);
	if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
	UserDet = SecMgr.getUserDetails(session.getId());
	session.setAttribute("UserDet",UserDet);
	issi.admin.ISSILogger.setSession(session);

	CmnMgr.setConnection(ConMgr);
	SQLMgr.setConnection(ConMgr);

	SQL2BeanBuilder sbb = new SQL2BeanBuilder();
	ArrayList al = new ArrayList();
	ArrayList alEmp = new ArrayList();
	CommonDataObject cdo = new CommonDataObject();
	int rowCount = 0;

	StringBuffer sbSqlGrupo = new StringBuffer();
	StringBuffer sbSqlEmp = new StringBuffer();

	String grupo = request.getParameter("grupo");
	String area = request.getParameter("uf_codigo");
	//String area = request.getParameter("area");
System.out.println(":::::::::::::::::::::::::::::::::::::::  GRUPO = "+grupo+" AND AREA = "+area);
	String sql = "";
	String compania = (String)session.getAttribute("_companyId");
	String appendFilter = "";

	String numEmpleado = (request.getParameter("numEmpleado")==null?"":request.getParameter("numEmpleado"));
	String nombreEmpleado = (request.getParameter("nombreEmpleado")==null?"":request.getParameter("nombreEmpleado"));
	String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
	String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));
	String fp = (request.getParameter("fp")==null?"":request.getParameter("fp"));

	if (grupo == null) grupo = "1";
	if (area == null) area = "1";


	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
	String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");

	XMLCreator xml = new XMLCreator(ConMgr);
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"areaXGrupo.xml","select codigo as value_col, codigo||' - '||nombre as label_col, "+compania+"||'-'||grupo as key_col from tbl_pla_ct_area_x_grupo order by 3,2");

if (request.getMethod().equalsIgnoreCase("GET")) {

	int recsPerPage = 50;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
	if (request.getParameter("searchQuery") != null)
	{
		nextVal = request.getParameter("nextVal");
		previousVal = request.getParameter("previousVal");
		if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
		if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
		if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
		if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
	}

	if (request.getParameter("empId") != null && !request.getParameter("empId").trim().equals(""))
	{
	   appendFilter += " and a.emp_id = "+empId;
	}

	sbSqlGrupo.append("select codigo, codigo||' - '||descripcion from tbl_pla_ct_grupo where compania = ");
	sbSqlGrupo.append(compania);
	if (!UserDet.getUserProfile().contains("0"))
	{
		sbSqlGrupo.append(" and codigo in (select grupo from tbl_pla_ct_usuario_x_grupo where usuario = '");
		sbSqlGrupo.append(session.getAttribute("_userName"));
		sbSqlGrupo.append("')");
	}
	sbSqlGrupo.append(" order by descripcion");
	if (grupo.trim().equals(""))
	{
		cdo = SQLMgr.getData(sbSqlGrupo.toString());
		if (cdo != null) grupo = cdo.getColValue("codigo");
	}

	if (grupo.equals("1")){
		sql = "/**GRUPO = 1***/select to_char(trans_desde,'dd/mm/yyyy') c_fecha_inicio, to_char(trans_hasta,'dd/mm/yyyy') c_fecha_final, periodo v_periodo, fecha_inicial v_fecha_ini from tbl_pla_calendario where tipopla = 1 and fecha_cierre+5  >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') and  fecha_inicial = (select min(x.fecha_inicial) from tbl_pla_calendario x where x.tipopla = 1 and   x.fecha_cierre+5  >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') ) and rownum = 1";
	}else{
	   sql = "select to_char(trans_desde,'dd/mm/yyyy') c_fecha_inicio, to_char(trans_hasta,'dd/mm/yyyy') c_fecha_final ,periodo v_periodo, fecha_inicial v_fecha_ini  from tbl_pla_calendario where tipopla  = 1 and fecha_cierre+2  >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') and  fecha_inicial = (select min(x.fecha_inicial) from tbl_pla_calendario x where x.tipopla = 1 and   x.fecha_cierre+2  >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') ) and rownum = 1";
	}

	cdo = SQLMgr.getData("select xx.* ,decode(mod(xx.v_periodo,2),0,'2da','1ra')||'  QUINCENA  DE  '||to_char(xx.v_fecha_ini,'FMMONTH','NLS_DATE_LANGUAGE=SPANISH')||'  DE  '||to_number(to_char(v_fecha_ini,'YYYY')) dsp_periodo_activo from("+sql+") xx");

	sbSqlEmp.append("select b.emp_id, to_char(a.provincia,'FM09') provincia,a.sigla, to_char(a.tomo,'FM0009') tomo, to_char(a.asiento,'FM0000009') asiento,a.num_empleado, b.primer_nombre||' '||b.primer_apellido||' '||decode(b.sexo,'F',decode(b.apellido_casada,null,b.segundo_apellido,b.apellido_casada),'M',b.segundo_apellido) nombre from tbl_pla_ct_empleado a, tbl_pla_empleado b where b.emp_id = a.emp_id and b.compania = a.compania and b.num_empleado = a.num_empleado and a.grupo = ");
	sbSqlEmp.append(grupo);
	sbSqlEmp.append(" and a.compania = ");
	sbSqlEmp.append(compania);
	sbSqlEmp.append(" and a.fecha_ingreso_grupo <= to_date('");
	sbSqlEmp.append(cdo.getColValue("c_fecha_final"));
	sbSqlEmp.append("','dd/mm/yyyy')");
	sbSqlEmp.append(" and (a.fecha_egreso_grupo is null or a.fecha_egreso_grupo >= to_date('");
	sbSqlEmp.append(cdo.getColValue("c_fecha_inicio"));
	sbSqlEmp.append("','dd/mm/yyyy') )");
		if (area != "" )
			{

	sbSqlEmp.append(" and nvl(a.ubicacion_fisica,1) = ");
	sbSqlEmp.append(area);
		}
	sbSqlEmp.append(" and (b.provincia,b.sigla,b.tomo,b.asiento, b.num_empleado,b.compania) in (select e.provincia,e.sigla,e.tomo,e.asiento, e.num_empleado,e.compania from  tbl_pla_empleado e, tbl_pla_cargo c where c.codigo = e.cargo and   c.compania = e.compania and   c.denominacion not like 'GERENTE%' and   c.denominacion not like 'DIRECTOR%' and   c.denominacion not like 'SUB-DIRECTOR%' and   c.denominacion not like 'SUB-JEFE%' and   c.denominacion not like 'VICE-PRESID%' and   c.denominacion not like 'JEFE%'  and   e.compania = ");
	sbSqlEmp.append(compania);
	sbSqlEmp.append(") ");
	sbSqlEmp.append(appendFilter);
	sbSqlEmp.append(" order by b.num_empleado");


	alEmp = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSqlEmp.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	rowCount = CmnMgr.getCount("select count(*) count FROM ("+sbSqlEmp.toString()+")");

	if (searchDisp!=null) searchDisp=searchDisp;
	else searchDisp = "Listado";
	if (!searchVal.equals("")) searchValDisp=searchVal;
	else searchValDisp="Todos";

	int nVal, pVal;
	int preVal=Integer.parseInt(previousVal);
	int nxtVal=Integer.parseInt(nextVal);
	if (nxtVal<=rowCount) nVal=nxtVal;
	else nVal=rowCount;
	if(rowCount==0) pVal=0;
	else pVal=preVal;

	System.out.println(":::::::::::::::::::::::::::::::::::::::THEBRAIN SAYS GRUPO = "+grupo+" AND AREA = "+area);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'RRHH - '+document.title;

function doAction(){

overrideLoadXML(<%=grupo%>);
}

function printRpt(){
var grupo=document.search01.grupo.value;
var area=document.search01.uf_codigo.value;
var fg=document.search01.fg.value;
var anio= "<%=cdo.getColValue("c_fecha_inicio").substring(6,10)%>";
var periodo= "<%=cdo.getColValue("v_periodo")%>";
var empId= (document.search01.empId.value==""?"0":document.search01.empId.value);

abrir_ventana('../cellbyteWV/report_container.jsp?reportName=rhplanilla/rpt_reporte_de_sobretiempo.rptdesign&pUnit='+grupo+'&pFlag='+fg+'&pArea='+area+'&pAnio='+anio+'&pPeriodo='+periodo+'&pCtrlHeader=false&pEmpId='+empId);
}

function selEmpleado(){
var grupo=document.search01.grupo.value;
var area=document.search01.uf_codigo.value;
    abrir_ventana('../common/search_empleado.jsp?fp=cons_sobretiempo&grupo='+grupo+'&area='+area);
}

function overrideLoadXML(value){
   loadXML('../xml/areaXGrupo.xml','uf_codigo','','VALUE_COL','LABEL_COL','<%=compania%>-'+value,'KEY_COL','T');
}
function edit(area,grupo,empId,nombre){
abrir_ventana('../rhplanilla/sobretiempo_list_det.jsp?grupo=<%=grupo%>&area=<%=area%>&nombre='+nombre+'&empId='+empId);
}

function approve(k){var nombre=eval('document.form1.nombre'+k).value;var empId=eval('document.form1.empId'+k).value;showPopWin('../rhplanilla/sobretiempo_list_det.jsp?fg=<%=fg%>&grupo=<%=grupo%>&nombre='+nombre+'&empId='+empId+'&__ct='+(new Date()).getTime(),winWidth*.95,_contentHeight*.75,null,null,'');}

function chkOver(){
	var size = document.form1.size.value;
	var grupo = document.form1.grupo.value;
	var x = 0;
	var empId = 0;
	if(confirm('¿Está seguro que desea Actualizar los Sobretiempos ??'))
	{
	for(i=0;i<size;i++){
		if(eval('document.form1.chk'+i) != null && eval('document.form1.chk'+i).checked==true){
			empId = eval('document.form1.empId'+i).value;	
				if(executeDB('<%=request.getContextPath()%>','call sp_pla_update_sobretiempo(<%=(String) session.getAttribute("_companyId")%>,'+empId+','+grupo+')',''))
					{ x++;
					} else alert('No se han generado las actualizaciones Revisar....'); }
	}  // end for
	} else alert('Proceso cancelado!');
	if(x==0) 
	return true;
	 else { alert('Proceso terminado Satisfactoriamente');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=ap&empId=<%=empId%>&grupo=<%=grupo%>';
	}
}
function checkAll()
{
	var size = document.form1.size.value;
	for (i=0; i<size; i++)
	{  if (eval(document.form1.modular).checked) {
		   eval('document.form1.chk'+i).checked=true;
		} else {
		eval("document.form1.chk"+i).checked = false; }
	}
}


</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="REGISTRO DE SOBRETIEMPO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="1" id="_tblSearch">
<!-- =====================   S E A R C H   E N G I N E S   S T A R T   H E R E   ===================== -->
	<tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<% fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp"); %>
					<%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<td>
						Grupo<%=fb.select(ConMgr.getConnection(),sbSqlGrupo.toString(),"grupo",grupo,false,false,0,"Text10",null,"onChange=\"overrideLoadXML(this.value)\"")%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						Ubic./Area Trab.<%=fb.select("uf_codigo",area,"",false,false,0,"Text10","","")%>
						<script language="javascript">
						loadXML('../xml/areaXGrupo.xml','uf_codigo','<%=area%>','VALUE_COL','LABEL_COL','<%=grupo%>','KEY_COL','0');
						</script>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						Empleado:<%=fb.textBox("numEmpleado",""+numEmpleado,false,false,true,5,"Text10",null,null)%>
						<%=fb.textBox("nombreEmpleado",""+nombreEmpleado,false,false,true,25,"Text10",null,null)%>
						<%=fb.hidden("empId",""+empId)%>

						<%=fb.button("getEmpData","...",false,false,"Text10","","onClick=\"javascript:selEmpleado();\"")%>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<%=fb.submit("go","Ir")%>
				    </td>
					<%=fb.formEnd(true)%>
				</tr>
			</table>
		</td>
	</tr>
	<!-- ============================== TOP PREVIOUS / NEXT ===============================-->
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("nombreEmpleado",nombreEmpleado)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

					<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("nombreEmpleado",nombreEmpleado)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
			    </tr>
		    </table>
	    </td>
    </tr>
<!-- ===========================   S E A R C H   E N G I N E S   E N D   H E R E   ========================== -->

	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("errCode","")%>
	<%=fb.hidden("errMsg","")%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("grupo",grupo)%>
	<%=fb.hidden("area",area)%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	

	<tr class="TextRow01 ">
	  <td class="TableLeftBorder TableBottomBorder TableRightBorder">
		 <table width="100%" cellpadding="1" cellspacing="1">
		 <tbody id="list">
			 <tr class="TextHeader01">
				<td colspan="4" width="30%" align="center">C&eacute;dula</td>
				<td width="40%">Nombre del Empleado</td>
				<td width="10%" align="center">No. Empleado</td>
				<td width="20%" align="center">
				  	<%=fb.button("imprimir","Imprimir",false,false,"Text10","","onClick=\"javascript:printRpt();\"")%>
					
					<% if (!fp.equalsIgnoreCase("asistencia")) {
				%>
					
					<%=fb.button("saveUP","Aprobar",false,false,"","","onClick=\"javascript:chkOver()\"")%>
				 <td align="center" width="4%">
					<%=fb.checkbox("modular","",false,false,null,null,"onClick=\"javascript:checkAll()\"")%>
				</td>
				 
				<% }  %>
				</td>
				
			 </tr>
			 <% for (int e = 0; e<alEmp.size(); e++){
				cdo = (CommonDataObject)alEmp.get(e);

				String color = "TextRow02";
				if (e % 2 == 0) color = "TextRow01";
			 %>
				 <%=fb.hidden("nombre"+e,cdo.getColValue("nombre"))%>
				 <%=fb.hidden("empId"+e,cdo.getColValue("emp_id"))%>
				 <tr id="rs<%=e%>"  class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center"><%=cdo.getColValue("provincia")%></td>
					<td align="center"><%=cdo.getColValue("sigla")%></td>
					<td align="center"><%=cdo.getColValue("tomo")%></td>
					<td align="center"><%=cdo.getColValue("asiento")%></td>
					<td><%=cdo.getColValue("nombre")%></td>
					<td align="center"><%=cdo.getColValue("num_empleado")%></td>
				<% if (!fp.equalsIgnoreCase("asistencia")) {
				%>
					<td align="center">
					   <a class="Link02Bold" href="javascript:approve(<%=e%>)">Ver detalle</a>
					</td>
					<td align="center"><%=fb.checkbox("chk"+e,""+e, false, false, "text10", "", "")%></td>
				<% } else { %>
				<td align="center">
			<authtype type='4'><a href="javascript:edit(<%=area%>,'<%=grupo%>',<%=cdo.getColValue("emp_id")%>,'<%=cdo.getColValue("nombre")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Editar</a></authtype>
					</td>
					<% }  %>

					

				 </tr>
			 <% }//for e%>
			 </tbody>
		 </table>
	  </td>
	</tr>
	<%=fb.hidden("size",""+alEmp.size())%>
<%=fb.formEnd(true)%>

<!-- =====================   S E A R C H   E N G I N E S   S T A R T   H E R E   ===================== -->
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<% fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("nombreEmpleado",nombreEmpleado)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%">Total Registro(s) <%=rowCount%></td>
					<td width="40%" align="right">Registros desde <%=pVal%> hasta <%=nVal%></td>

					<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
					<%=fb.hidden("grupo",grupo)%>
					<%=fb.hidden("area",area)%>
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("nombreEmpleado",nombreEmpleado)%>
					<%=fb.hidden("empId",empId)%>
					<%=fb.hidden("numEmpleado",numEmpleado)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
<!-- ===========================   S E A R C H   E N G I N E S   E N D   H E R E   ========================== -->


</table>
</body>
</html>
<%
}//GET
else
{
  String baction = request.getParameter("baction");
  fg = request.getParameter("fg");
  int size = Integer.parseInt(request.getParameter("size"));
  int cnt = 0;
  // alEmp.clear();

   if (baction.equalsIgnoreCase("Aprobar")) {
	   if (alEmp.size() > 0){
	        
			  for (int i=0; i<size; i++) {
					System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>UPDATING AL SIZE  = "+alEmp.size());
					SQLMgr.setErrCode("1");
		   SQLMgr.setErrMsg("Como que no ha cambiado nada, tampoco actualizaremos la base de datos!");
		    }//for i
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	<% if(!fg.equals("")) {
	%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=ap&empId=<%=empId%>&grupo=<%=grupo%>';
	<% } else { %>


	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?empId=<%=empId%>&grupo=<%=grupo%>';
<%
} } else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>