
<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.presupuesto.Presupuesto"%>
<%@ page import="issi.presupuesto.PresDetail"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="PresMgr" scope="page" class="issi.presupuesto.PresupuestoMgr" />

<%
/**
==========================================================================================
fg = PI = presupuesto de inversion
fp = PA  PRE - APROBACION DE PRESUPUESTOS DE INVERSION 
   = VB  VOBO DE LAS INVERSIONES
   = AP  APROBACION DE LAS INVERSIONES
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
PresMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo= new CommonDataObject();
int rowCount = 0;
StringBuffer sql = new StringBuffer();
String appendFilter = "";
String unidad="";
String fpFilter = "";
String anio = request.getParameter("anio");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");

if(fg==null) fg = "PI";
if(fp==null) fp = "PA";
String cDateTime= CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if(anio ==null)anio=cDateTime.substring(6, 10);

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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

	if (request.getParameter("anio") != null && !request.getParameter("anio").trim().equals(""))
	{
		appendFilter += " and a.anio = "+request.getParameter("anio");
    	anio = request.getParameter("anio");
	} 
	if (request.getParameter("unidad") != null && !request.getParameter("unidad").trim().equals(""))
	{
		appendFilter += " and a.codigo_ue = "+request.getParameter("unidad");
    	unidad = request.getParameter("unidad");
	} 
	if(fp.trim().equals("PA")){
		fpFilter =" and  a.estado ='E' /*(a.preaprobado = 'N' or a.preaprobado is null)*/ ";
	}
	else if(fp.trim().equals("VB")){
		fpFilter =" and a.estado ='C' /*nvl(a.preaprobado,'N') = 'S' and nvl(a.vobo_estado,'N') = 'N'*/ ";
	}
	else if(fp.trim().equals("AP")){
		fpFilter =" and a.estado='V' /*nvl(a.preaprobado,'N') = 'S' and nvl(a.vobo_estado,'N') = 'S' and	 (nvl(a.aprobado,'N') = 'N' or a.aprobado is null) */ ";
	}

	if (request.getParameter("anio") != null)
	{
		sql.append("select a.anio, a.compania, a.codigo_ue unidad, b.descripcion descUnidad, nvl(a.solicitado,0) monto,(select  descripcion from tbl_con_tipo_inversion where tipo_inv = a.tipo_inv and compania = a.compania) descTipoInv ,a.tipo_inv, a.consec,a.solicitado,a.descripcion,a.categoria,a.prioridad,a.comentario,a.preaprobado, a.cantidad from tbl_con_ante_inversion_anual a, tbl_sec_unidad_ejec b where a.compania = ");
		sql.append(((String) session.getAttribute("_companyId")));
		sql.append(appendFilter);
		sql.append(" and b.codigo = a.codigo_ue and b.compania = a.compania /*and  nvl(a.estado,'B') = 'E' */");
		sql.append(fpFilter);
		sql.append(" order by b.descripcion, a.codigo_ue");
		
	al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
	rowCount = CmnMgr.getCount("select count(*) count from ("+sql+")");



	
	}
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
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = '<%=(fp.equals("PA"))?"Pre-aprobaci&oacute;n de Presupuesto De Inversiones":"VoBo / Anulaci&oacute;n de Presupuesto de Inversi&oacute;n"%>  - '+document.title;

function checkAprob()
{
	var cantidad = 0;  
	var anio = document.search01.anio.value;
	var baction = document.form1.baction.value;
	if(baction =='Pre - Aprobar' ||baction =='Anular' || baction =='VoBo' || baction =='Aprobar')
	{
	   if(anio !='')
	   {
	   		for(i=0;i<<%=al.size()%>;i++)
			{
				var sel ='';
				if(eval('document.form1.check'+i).value != '')sel =eval('document.form1.check'+i).value;
		
				if(eval('document.form1.check'+i).checked ||sel !='')
				{	
					cantidad ++;
				}
			}
	   }
	   else alert('Introduzca El Año');
	}
	
	if(baction =='Pre - Aprobar')
	{
		if(cantidad == 0){alert('Seleccione los presupuesto a pre - aprobar!!');return false;}
		else{if(confirm('Este proceso PRE-APROBARA el presupuesto preelimnar de las unidades seleccionadas.  Seguro que desea ejecutarlo?')){
		return true}else{return false;}};
	}
	else if(baction =='Rechazar Presupuesto')
	{
		if(confirm('Este proceso CERRARA el presupuesto preelimnar de las unidades seleccionadas y todas las inversiones NO APROBADAS serán RECHAZADAS.  Seguro que desea ejecutarlo?')){	return true;}else{ return false;}
	}
	else if(baction =='Anular')
	{
		if(cantidad == 0){alert('Seleccione los presupuesto a Anular!!');return false;}else{
		if(confirm('Este proceso ANULARA la pre-aprobacion de las inversiones de las unidades seleccionadas.  Seguro que desea ejecutarlo?')){return true;}else{ return false;}}
	}
	else if(baction =='VoBo')
	{
		if(cantidad == 0){alert('Seleccione las inversiones a Aprobar!!');return false;}else{
		if(confirm('Este proceso enviará las inversiones seleccionadas para APROBACION en la Gerencia General.  Seguro que desea ejecutarlo?')){return true;}else{ return false;}}
	}
	else if(baction =='Aprobar')
	{
		if(cantidad == 0){alert('Seleccione las inversiones a Aprobar o Rechazar!!');return false;}else{
		if(confirm('Este proceso APROBARÁ el presupuesto preelimnar de las unidades seleccionadas.  Seguro que desea ejecutarlo??')){return true;}else{ return false;}}
	}
}
function  checkSel(fName,objName,alSize,value,fElement)
{
	checkAll(fName,objName,alSize,value,fElement);
	calSeleccion();
}
function  calSeleccion()
{
	var total  =0;
	var cantidad =0;
	for(i=0;i<<%=al.size()%>;i++)
	{	
		var sel ='';
		if(eval('document.form1.check'+i).value == 'S')sel ='S';

		if(eval('document.form1.check'+i).checked ||sel=='S')
		{	
			cantidad ++;
			total  += parseFloat(eval('document.form1.solicitado'+i).value);
		}
	}
	document.form1.totalChk.value=(total).toFixed(2);
}
function  checkItem(k)
{
	var total     = parseFloat(document.form1.totalChk.value);
	var sel ='';
	if(eval('document.form1.check'+k).value == 'S')sel ='S';
			
	if(eval('document.form1.check'+k).checked || sel =='S')
	{	
		total  += parseFloat(eval('document.form1.solicitado'+k).value);
		document.form1.totalChk.value=(total).toFixed(2);
	}
	else
	{
		if(total != 0) total  -= parseFloat(eval('document.form1.solicitado'+k).value);
		document.form1.totalChk.value=(total).toFixed(2);
	}
}
function reloadPage(unidad){
	var anio = document.search01.anio.value;
	window.location = '../presupuesto/list_preaprob_presInv.jsp?fg=<%=fg%>&fp=<%=fp%>&unidad='+unidad+'&anio='+anio;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PRESUPUESTO DE INVERSIONES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<tr>
	<td align="right"></td>
</tr>
<tr>
	<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<table width="100%" cellpadding="0" cellspacing="0">
		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
		<%=fb.formStart()%>
		<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<tr class="TextFilter">
			<td width="44%">
				<cellbytelabel>A&ntilde;o</cellbytelabel>
				<%=fb.intBox("anio",anio,false,false,false,10)%>
		  </td>
			<td width="56%">
				<cellbytelabel>Unidad</cellbytelabel>
				<%//=fb.intBox("unidad",unidad,false,false,false,10)%>
				<%=fb.select(ConMgr.getConnection(), "select distinct a.codigo_ue unidad, b.descripcion, b.descripcion x from 	tbl_con_ante_inversion_anual a, tbl_sec_unidad_ejec b where a.compania = " + (String) session.getAttribute("_companyId") +" and a.anio = "+anio+" and b.codigo = a.codigo_ue and b.compania = a.compania /*and  nvl(a.estado,'B') = 'E'*/ "+fpFilter+" order by b.descripcion, a.codigo_ue", "unidad",unidad, false, false, 0, "", "", "onChange=\"javascript:reloadPage(this.value);\"", "Unidad Administrativa", "T")%>
				<%=fb.submit("go","Ir")%>
				<%//=fb.button("borrador","BORRADOR",true,false,null,null,"onClick=\"javascript:presBorrador()\"")%>
		  </td>
		<%=fb.formEnd()%>
		</tr>
		</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

	</td>
</tr>
<tr>
	<td align="right">&nbsp;</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
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
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
		<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
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

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
		<%=fb.hidden("size",""+al.size())%>
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
		<%=fb.hidden("baction","")%>
		<tr class="TextHeader" align="center">
			<td width="29%"><cellbytelabel>Unidad</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Tipo Inv</cellbytelabel>.</td>
			<td width="9%"><cellbytelabel>Cantidad</cellbytelabel></td>
			<td width="21%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Tipo Apoyo</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Prioridad</cellbytelabel></td>
			<td width="9%"><cellbytelabel>Inversi&oacute;n</cellbytelabel></td>
            <td width="5%"><%if(!fp.trim().equals("AP")){%><%if(fp.trim().equals("PA")){%>Pre - Aprob.<%} else {%>VoBo<%}%><br><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkSel('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Registros listados!")%><%}else{%>Acci&oacute;n<%}%></td>
		</tr>
		<%double total =0;
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cdo2 = (CommonDataObject) al.get(i);
			String color = "TextRow02";
			if (i % 2 == 0) color = "TextRow01";
				 total += Double.parseDouble(cdo2.getColValue("monto"));
				/*double totalTemp = Math.round((total) * 100);
				totalTemp = Math.round((total) * 100)/100;
				total = totalTemp;*/
				%>
			<%=fb.hidden("anio"+i,cdo2.getColValue("anio"))%>
			<%=fb.hidden("unidad"+i,cdo2.getColValue("unidad"))%>
			<%=fb.hidden("compania"+i,cdo2.getColValue("compania"))%>
			<%=fb.hidden("tipo_inv"+i,cdo2.getColValue("tipo_inv"))%>
			<%=fb.hidden("consec"+i,cdo2.getColValue("consec"))%>
			
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td><%=cdo2.getColValue("descUnidad")%></td>
				<td><%=cdo2.getColValue("descTipoInv")%>&nbsp;</td>
				<td align="center"><%=cdo2.getColValue("cantidad")%></td>
				<td><%=fb.textarea("comentario"+i,cdo2.getColValue("comentario"),false,false,true,30,2,2000)%></td>
				<td><%=fb.select("categoria"+i,"1=GEN. DE INGRESO,2=SERVICIOS DE APOYO OPER.,3=SERVICIOS DE APOYO ADM.",cdo2.getColValue("categoria"),false,true,0,"text10","","","","")%></td>
				<td><%=fb.select("prioridad"+i,"1=URGENTE,2=MUY NECESARIO,3=NECESARIO",cdo2.getColValue("prioridad"),false,true,0,"text10","","","","")%></td>
				<td><%=fb.decBox("solicitado"+i,""+cdo2.getColValue("monto"),true,false,true,10)%></td>
				<td align="center" rowspan="2"><%if(!fp.trim().equals("AP")){%><%=fb.checkbox("check"+i,""+i,false,false,"","","onClick=\"javascript:checkItem("+i+")\"","")%>
				<%}else{%><%=fb.select("check"+i,"S=APROBAR,N=PENDIENTE,R=RECHAZAR","",false,false,0,"","","onChange=\"javascript:checkItem("+i+")\"","","S")%>
				<%}%>
				</td>
			</tr>
			<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
				<td>Justificaci&oacute;n</td>
				<td colspan="6"><%=fb.textarea("descripcion"+i,cdo2.getColValue("descripcion"),false,false,true,80,2,2000)%></td>
			</tr>
		<%
		}
		%>
		
		<tr class="TextRow02">
          <td align="right" colspan="7"><cellbytelabel>Inversi&oacute;n Total Solicitado</cellbytelabel> =></td>
		  <td><%=fb.decBox("totalSolicitado",""+total,false,false,true,10,"Text10",null,null)%></td>
        </tr>
		<tr class="TextRow02">
          <td align="right" colspan="7"><cellbytelabel>Inversi&oacute;n Total Seleccionada</cellbytelabel> =></td>
		  <td><%=fb.decBox("totalChk","0",false,false,true,10,"Text10",null,null)%></td>
        </tr>
			
		<tr class="TextRow02">
		  <%if(fp.trim().equals("PA")){//pre - aprobacion %>
		  <td colspan="4" align="left">
			<authtype type='53'><%=fb.submit("cerrar","Rechazar Presupuesto",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		  <td colspan="4" align="right">
			<authtype type='52'><%=fb.submit("save","Pre - Aprobar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		 <%}else if(fp.trim().equals("VB")){// vobo y anulacion de pre - aprobacion%>
		  <td colspan="4" align="left">
		  	<authtype type='50'><%=fb.submit("anular","Anular",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		  <td colspan="4" align="right">
		  	<authtype type='51'><%=fb.submit("vobo","VoBo",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		  <%}else if(fp.trim().equals("AP")){//aprobacion%>
		  <td colspan="8" align="right">
		  	<authtype type='6'><%=fb.submit("save","Aprobar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></authtype>
		  </td>
		  <%}%>
        </tr>
		</table>
		<%//if(fp.equals("CD")){fb.appendJsValidation("\n\tif (!checkEstado())\n\t{\n\t\terror++;\n\t}\n");}%>
		<%fb.appendJsValidation("\n\tif (!checkAprob())\n\t{\n\t\terror++;\n\t}\n");%>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</td>
</tr>

</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableBottomBorder TableRightBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="0">
		<tr class="TextPager">
		<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
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
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
			<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
		<%=fb.formEnd()%>
			<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
			<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
		<%=fb.hidden("fg",fg)%>
		<%=fb.hidden("fp",fp)%>
		<%=fb.hidden("anio",anio)%>
		<%=fb.hidden("unidad",unidad)%>
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
}//End Method GET
else if (request.getMethod().equalsIgnoreCase("POST"))
{ // Post
ArrayList al1= new ArrayList();
 int size =Integer.parseInt(request.getParameter("size"));
 String baction = request.getParameter("baction");
	
	Presupuesto presup = new Presupuesto();
	presup.setFg(fg);
	presup.setFp(fp);
	//if(fg.trim().equals("AP"))presup.setFg(fg);
	presup.setAnio(request.getParameter("anio"));
	presup.setCompania((String) session.getAttribute("_companyId"));
	presup.setUsuarioModificacion((String) session.getAttribute("_userName"));

	if (baction != null && !baction.equalsIgnoreCase("VoBo") && !baction.equalsIgnoreCase("Aprobar"))
	{
		presup.setPreaprobadoUsuario((String) session.getAttribute("_userName"));
		presup.setPreaprobadoFecha(cDateTime);
		
		if (baction != null && baction.equalsIgnoreCase("Pre - Aprobar")){
			presup.setEstado("C");
			presup.setPreaprobado("S");}
		else if (baction != null && baction.equalsIgnoreCase("Rechazar Presupuesto")){
			presup.setPreaprobado("R"); 
			presup.setEstado("R"); 
			System.out.println("presup.setPreaprobado( ="+presup.getPreaprobado());}
		else if (baction != null && baction.equalsIgnoreCase("Anular")){
			presup.setEstado("N");
			presup.setPreaprobado("N");}
			System.out.println("presup.setPreaprobado( ="+presup.getPreaprobado());
	}
	else if (baction != null && baction.equalsIgnoreCase("VoBo"))
	{
			presup.setEstado("V");
			presup.setVoboEstado("S");
			presup.setVoboFecha(cDateTime);
			presup.setVoboUsuario((String) session.getAttribute("_userName"));
	}
	else if (baction != null && baction.equalsIgnoreCase("Aprobar"))
	{
			//presup.setAprobado("S");
			//presup.setAprobadoFecha(cDateTime);
			//presup.setUsuarioAprob((String) session.getAttribute("_userName"));
	}
	
	
	 for(int i=0;i<size;i++)
	 {
	   if (baction != null && !baction.equalsIgnoreCase("Rechazar Presupuesto")&& !baction.equalsIgnoreCase("Aprobar"))
	   { 
	       if (request.getParameter("check"+i) != null)
		   {
					PresDetail presDet = new PresDetail();
					presDet.setUnidad(request.getParameter("unidad"+i));
					presDet.setTipoInv(request.getParameter("tipo_inv"+i));
					presDet.setConsec(request.getParameter("consec"+i));
					presDet.setPreaprobado(presup.getPreaprobado());
					presDet.setEstado(presup.getEstado());
					presup.getPresDetail().add(presDet);
			}
		}//Cerrar Presupuesto
		else if (baction != null && baction.equalsIgnoreCase("Rechazar Presupuesto"))
		{
				PresDetail presDet = new PresDetail();
				presDet.setUnidad(request.getParameter("unidad"+i));
				presDet.setTipoInv(request.getParameter("tipo_inv"+i));
				presDet.setConsec(request.getParameter("consec"+i));

				if (request.getParameter("check"+i) != null)
		   		{
					presDet.setEstado("C");
					presDet.setPreaprobado("S");
				}
				else 
				{
					presDet.setPreaprobado("R");
					presDet.setEstado("R");
				}
				
				presup.getPresDetail().add(presDet);
		}
		else if (baction != null && baction.equalsIgnoreCase("Aprobar"))
		{
				PresDetail presDet = new PresDetail();
				presDet.setUnidad(request.getParameter("unidad"+i));
				presDet.setTipoInv(request.getParameter("tipo_inv"+i));
				presDet.setConsec(request.getParameter("consec"+i));
				
				if (request.getParameter("check"+i) != null && !request.getParameter("check"+i).trim().equals(""))
		   		{
					presDet.setAprobado(request.getParameter("check"+i));
					//presDet.setEstado(presup.getEstado());
					
					if (request.getParameter("check"+i).trim().equals("S"))
					{
						// encabezado
						presup.setEstado("A");
						presup.setAprobado("S");
						presup.setAprobadoFecha(cDateTime);
						presup.setUsuarioAprob((String) session.getAttribute("_userName"));
						// detalle
						presDet.setEstado("A");
						presDet.setAprobado("S");
						presDet.setFechaAprob(cDateTime);
						presDet.setUsuarioAprob((String) session.getAttribute("_userName"));
					} else if (request.getParameter("check"+i).trim().equals("R"))
					{
						// encabezado
						presup.setEstado("R");
						presup.setAprobado("N");
						presup.setFechaRechazo(cDateTime);
						// detalle
						presDet.setEstado("R");
						presDet.setAprobado("N");
						presDet.setFechaRechazo(cDateTime); 
					} 
			//presup.setAprobado("S");
			//presup.setAprobadoFecha(cDateTime);
			//presup.setUsuarioAprob((String) session.getAttribute("_userName"));
				}
				
				presup.getPresDetail().add(presDet);
		}
	 }
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	if (baction != null && (baction.equalsIgnoreCase("Pre - Aprobar") || baction.equalsIgnoreCase("Rechazar Presupuesto")|| baction.equalsIgnoreCase("Anular")|| baction.equalsIgnoreCase("VoBo") || baction.equalsIgnoreCase("Aprobar")))
	{
		PresMgr.preAprobPres(presup);
	}
	 
	ConMgr.clearAppCtx(null);
  		
  
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (PresMgr.getErrCode().equals("1"))
{
%>
	alert('<%=PresMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/presupuesto/list_preaprob_presInv.jsp"))
	{
%>
	window.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/presupuesto/list_preaprob_presInv.jsp")%>';
<%
	}
	else
	{
%>
	window.location = '<%=request.getContextPath()%>/presupuesto/list_preaprob_presInv.jsp?fg=<%=fg%>&fp=<%=fp%>';
<%
	}
%>
	//window.close();
<%
} else throw new Exception(PresMgr.getErrMsg());
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
