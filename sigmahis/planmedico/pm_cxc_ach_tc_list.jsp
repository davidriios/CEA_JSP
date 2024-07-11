<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String fecha_ini = request.getParameter("fecha_ini");
String fecha_fin = request.getParameter("fecha_fin");
if(fecha_ini==null) fecha_ini="";
if(fecha_fin==null) fecha_fin="";
String tipo_trx = request.getParameter("tipo_trx");
String cDateTime = CmnMgr.getCurrentDate("mm/yyyy");
if(mes == null) mes ="";//+Integer.parseInt(cDateTime.substring(0, 2));
if(anio == null) anio = cDateTime.substring(3, 7);
String estado="P";
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");
System.out.println("mes.................= "+mes+", cDateTime="+cDateTime);
if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  if(request.getParameter("estado")!=null) estado = request.getParameter("estado");
	if(tipo_trx==null) tipo_trx = "";
	
	sbSql.append("select id, lpad(mes, 2, '0') mes, decode(mes, 1, 'ENERO', 2, 'FEBRERO', 3, 'MARZO', 4, 'ABRIL', 5, 'MAYO', 6, 'JUNIO', 7, 'JULIO', 8, 'AGOSTO', 9, 'SEPTIEMBRE', 10, 'OCTUBRE', 11, 'NOVIEMBRE', 12, 'DICIEMBRE') mes_desc, anio, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_aprobacion, fecha_aprobacion, tipo_trx, estado, decode(estado, 'P', 'Pendiente', 'A', 'Aprobado', 'I', 'Inactivo') estado_desc, decode(tipo_trx, 'ACH', 'ACH', 'TC', 'TARJETA CREDITO', 'M', 'MANUAL') tipo_trx_desc from tbl_pm_regtran where tipo_trx in ('ACH', 'TC', 'M')");
	sbSql.append(" and compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	if(!estado.equals("")){
		sbSql.append(" and estado = '");
		sbSql.append(estado);
		sbSql.append("'");
	}	
	if(!anio.equals("")){
		sbSql.append(" and anio = ");
		sbSql.append(anio);
	}
	if(!mes.equals("")){
		sbSql.append(" and mes = ");
		sbSql.append(mes);
	}	
	if(!tipo_trx.equals("")){
		sbSql.append(" and tipo_trx = '");
		sbSql.append(tipo_trx);
		sbSql.append("'");
	}
	if(!fecha_ini.equals("")){
		sbSql.append(" and trunc(fecha_creacion) >= to_date('");
		sbSql.append(fecha_ini);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	if(!fecha_fin.equals("")){
		sbSql.append(" and trunc(fecha_creacion) <= to_date('");
		sbSql.append(fecha_fin);
		sbSql.append("', 'dd/mm/yyyy')");
	}
	
	sbSql.append(" order by id desc nulls last ");
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");

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

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Plan Medicico - Mantenimiento - Cuentionario Salud - '+document.title;

function doAction(){changeAltTitleAttr();}


function manageSurvey(option){
   if (typeof option == "undefined") abrir_ventana('../planmedico/reg_tc_ach.jsp');
   else if(option=='edit'){
      if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
			else	abrir_ventana('../planmedico/reg_tc_ach.jsp?mode=edit&id='+getCurVal());
   } else if(option=='view'){
      if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
      else {
				var ind = document.getElementById("curIndex").value;
				var mes = document.getElementById("mes"+ind).value;
				var anio = document.getElementById("anio"+ind).value;
				abrir_ventana('../planmedico/reg_tc_ach.jsp?mode=view&id='+getCurVal()+'&mes='+mes+'&anio='+anio);
			}
   } else if(option=='printTrx'){
      if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
      else {
				var ind = document.getElementById("curIndex").value;
				var mes = document.getElementById("mes"+ind).value;
				var anio = document.getElementById("anio"+ind).value;
				var tipo_trx = document.getElementById("tipo_trx"+ind).value;
				var mesDesc = '';
				if(mes==1) mesDesc='Enero';
				else if(mes==2) mesDesc='Febrero';
				else if(mes==3) mesDesc='Marzo';
				else if(mes==4) mesDesc='Abril';
				else if(mes==5) mesDesc='Mayo';
				else if(mes==6) mesDesc='Junio';
				else if(mes==7) mesDesc='Julio';
				else if(mes==8) mesDesc='Agosto';
				else if(mes==9) mesDesc='Septiembre';
				else if(mes==10) mesDesc='Octubre';
				else if(mes==11) mesDesc='Noviembre';
				else if(mes==12) mesDesc='Diciembre';
				abrir_ventana("../planmedico/print_pm_ach_tc.jsp?anio="+anio+"&mesDesc="+mesDesc+"&idSol="+getCurVal()+"&tipoTrx="+tipo_trx);
			}
   } else if(option=='approve'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			var estado = document.getElementById("estado"+ind).value;
			var tipo_trx = document.getElementById("tipo_trx"+ind).value;
			 if(estado=='I') alert('La Solicitud está inactiva y no se puede aprobar!');
			 else if(estado=='A') alert('La Solicitud ya está aprobada!');
			else showPopWin('../process/pm_app_reg_ach_tc.jsp?mode=app&code='+getCurVal()+'&tipo_trx='+tipo_trx,winWidth*.65,_contentHeight*.55,null,null,'');
		}
	 } else if(option=='inactivate'){
		if (getCurVal() == "") alert("Por favor seleccione uno para poder seguir!");
		else {
			var ind = document.getElementById("curIndex").value;
			 var estado = document.getElementById("estado"+ind).value;
			 var tipo_trx = document.getElementById("tipo_trx"+ind).value;
			 if(estado=='I') alert('La Solicitud ya está inactiva!');
			 else if(estado=='A') alert('La Solicitud está aprobada y no se puede inactivar!');
			else showPopWin('../process/pm_app_reg_ach_tc.jsp?mode=ina&code='+getCurVal()+'&tipo_trx='+tipo_trx,winWidth*.65,_contentHeight*.75,null,null,'');
	}
	}
   /*else if(option=='print'){
      abrir_ventana('../planmedico/pm_print_empresa_list.jsp?fecha_inicio=<%//=fecha_inicio%>&estado=<%=estado%>&id_solicitud=<%//=id_solicitud%>&idEmpresa='+getCurVal());
   }*/
}

function changeAltTitleAttr(obj,type,ctx){
  var opt = {"edit":"Editar","print":"Imprimir"};
	if (typeof obj != "undefined" && typeof type != "undefined" && typeof ctx != "undefined"){
	  if (getCurVal()!=""){
		obj.alt = opt[type]+" "+ctx+" #"+getCurVal();
		obj.title = opt[type]+" "+ctx+" #"+getCurVal();
	  }
	}else{
	  document.getElementById("printImg").alt = "Imprimir Lote";
	  document.getElementById("editImg").alt = "Seleccione un Lote a Editar";
	  document.getElementById("printImg").title = "Imprimir Transaccion";
	  document.getElementById("viewImg").title = "Ver Lote";
	  document.getElementById("editImg").title = "Seleccione un Lote a Editar";
	  document.getElementById("appImg").title = "Aprobar Lote";
	  document.getElementById("inacImg").title = "Inactivar Lote";
		document.getElementById("viewImg").title = "Ver Lote";
	}
}

function getCurVal(){return document.getElementById("curVal").value;}
function setId(curVal,curIndex){document.getElementById("curVal").value = curVal;
document.getElementById("curIndex").value = curIndex;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:changeAltTitleAttr()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr><%//="[2] IMPRIMIR       [3] REGISTRAR       [4] EDITAR"  %>
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='3'>
			<img src="../images/add_survey.png" alt="Registrar Nueva Cuota" title="Registrar Nueva Cuota" onClick="javascript:manageSurvey()" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='1'>
			<img src="../images/ver_analisis.png" alt="Ver Cuota" title="Ver Cuota" onClick="javascript:manageSurvey('view')" onMouseOver="javascript:changeAltTitleAttr(this,'view','Solicitud')" id="viewImg" width="32px" height="32px"/>
			</authtype>&nbsp;
			<authtype type='4'>
			<img src="../images/edit_survey.png" onClick="javascript:manageSurvey('edit')" width="32px" height="32px" onMouseOver="javascript:changeAltTitleAttr(this,'edit','Empresa')" id="editImg"/>
			</authtype>&nbsp;
			<authtype type='2'>
			<img src="../images/printer.png" onClick="javascript:manageSurvey('printTrx')" onMouseOver="javascript:changeAltTitleAttr(this,'print','Transaccion')" id="printImg"/>
			</authtype>
			<authtype type='6'>
			<img src="../images/check.gif" onClick="javascript:manageSurvey('approve')" onMouseOver="javascript:changeAltTitleAttr(this,'approve','Solicitud')" id="appImg" height="30" width="30"/>
			</authtype>
			<authtype type='7'>
			<img src="../images/cancel.gif" onClick="javascript:manageSurvey('inactivate')" onMouseOver="javascript:changeAltTitleAttr(this,'inactivate','Solicitud')" id="inacImg" height="30" width="30"/>
			</authtype>
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<td colspan="2">&nbsp;<cellbytelabel id="2">
			&nbsp;<cellbytelabel>Estado:</cellbytelabel>&nbsp;
			<%=fb.select("estado","P=Pendiente,A=Aprobado,I=Inactivo",estado,"T")%>
			&nbsp;
			A&ntilde;o: <%=fb.textBox("anio",anio,false,false,false,5,4,"Text12","","")%>
			Mes: <%=fb.select("mes","1=Enero, 2=Febrero, 3=Marzo, 4=Abril, 5=Mayo, 6=Junio, 7=Julio, 8=Agosto, 9 = Septiembre, 10 = Octubre, 11 = Noviembre, 12 = Diciembre",mes,false,false,false,0,"Text12","","","","S")%>
			Tipo:<%=fb.select("tipo_trx","ACH=ACH, TC=TARJETA CREDITO, M=MANUAL",tipo_trx,false,false,false,0,"Text12","","")%>
			Fecha:
			<jsp:include page="../common/calendar.jsp" flush="true">
			<jsp:param name="noOfDateTBox" value="2" />
			<jsp:param name="nameOfTBox1" value="fecha_ini" />
			<jsp:param name="valueOfTBox1" value="<%=fecha_ini%>" />
			<jsp:param name="nameOfTBox2" value="fecha_fin" />
			<jsp:param name="valueOfTBox2" value="<%=fecha_fin%>" />
			<jsp:param name="fieldClass" value="Text10" />
			<jsp:param name="buttonClass" value="Text10" />
		</jsp:include>
			<%=fb.submit("go","Ir")%>
			</td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<!--<tr>
		<td align="right">
			<authtype type='0'><a href="javascript:printList()" class="Link00">[ <cellbytelabel id="4">Imprimir Lista</cellbytelabel> ]</a></authtype>
		</td>
	</tr>-->
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo_trx",tipo_trx)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo_trx",tipo_trx)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="10%">&nbsp;<cellbytelabel>Lista</cellbytelabel></td>
		<td width="20%">&nbsp;<cellbytelabel>Usuario Creaci&oacute;n</cellbytelabel></td>
		<td width="20%">&nbsp;<cellbytelabel>Fecha Creaci&oacute;n</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Mes</cellbytelabel></td>
		<td width="10%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
		<td width="15%"><cellbytelabel>Tipo</cellbytelabel></td>
		<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curVal","")%>
	<%=fb.hidden("curIndex","")%>
<%
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("anio"+i,cdo.getColValue("anio"))%>
				<%=fb.hidden("mes"+i,cdo.getColValue("mes"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("tipo_trx"+i,cdo.getColValue("tipo_trx"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id")%></td>
					<td><%=cdo.getColValue("usuario_creacion")%></td>
					<td><%=cdo.getColValue("fecha_creacion")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("mes_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("anio")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("tipo_trx_desc")%></td>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onClick=\"javascript:setId("+cdo.getColValue("id")+","+i+")\"")%>
					</td>
				</tr>
				<%
				}
				%>
<%=fb.formEnd(true)%>
</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo_trx",tipo_trx)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7">hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
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
				<%=fb.hidden("anio",anio)%>
				<%=fb.hidden("mes",mes)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo_trx",tipo_trx)%>
				<%=fb.hidden("fecha_ini",fecha_ini)%>
				<%=fb.hidden("fecha_fin",fecha_fin)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
%>