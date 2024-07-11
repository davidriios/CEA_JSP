<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.expediente.DetalleOrdenMed"%>
<%@ page import="issi.admision.CitaProcedimiento"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est? fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String cs = request.getParameter("cs");
String pac_id = request.getParameter("pac_id");
String admision = request.getParameter("admision");
String index = request.getParameter("index");
String cds = request.getParameter("cds");
String alSize = request.getParameter("al_size");

String compania = (String) session.getAttribute("_companyId");

String tab = request.getParameter("tab");
String codCita = request.getParameter("codCita");
String fechaCita = request.getParameter("fechaCita");
String context = request.getParameter("context")==null?"":request.getParameter("context");
String codigo="",descripcion="";
if (fg == null) fg = "";
if (cs == null) cs = "";
if (cds == null) cds = "";
if (index == null) index = "";
if (alSize == null) alSize = "0";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null){
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

  if (request.getParameter("codigo") != null && !request.getParameter("codigo").trim().equals("")){
    if(fp.equalsIgnoreCase("LIS") || fp.equalsIgnoreCase("RIS")) appendFilter += " and upper(b.codigo) like '%"+request.getParameter("codigo").toUpperCase()+"%'";
    else appendFilter += " and aa.codigo like '%"+request.getParameter("codigo")+"%'";
    codigo = request.getParameter("codigo");
  }
	if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals("")){
    if(fp.equalsIgnoreCase("LIS") || fp.equalsIgnoreCase("RIS") || fp.equalsIgnoreCase("BDS")) 
      appendFilter += " and upper(decode(b.observacion,null, b.descripcion,b.observacion)) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    else appendFilter += " and upper(aa.descripcion) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }

	if(fp.equalsIgnoreCase("LIS") || fp.equalsIgnoreCase("RIS") || fp.equalsIgnoreCase("BDS")){
      sql = "select distinct decode (b.observacion,null, b.descripcion,b.observacion) descripcion, b.codigo from tbl_cds_procedimiento_x_cds a, tbl_cds_procedimiento b, tbl_cds_centro_servicio c where a.cod_procedimiento = b.codigo and a.cod_centro_servicio = c.codigo "+appendFilter+" and b.estado = 'A' and c.interfaz = '"+fp+"' order by decode (b.observacion, null, b.descripcion, b.observacion)";
  } else if(fp.equalsIgnoreCase("MED")){
    
    // sql = "select aa.* from (select distinct bm.cod_articulo as codigo, upper(a.descripcion)||' [BANCO]' as descripcion from tbl_inv_articulo a, tbl_inv_articulo_bm bm where bm.compania = a.compania  and bm.cod_articulo = a.cod_articulo and a.compania = "+compania+" and a.estado = 'A' and bm.estado = 'A' and exists ( select null from tbl_sec_cds_almacen a,tbl_inv_almacen b,tbl_inv_inventario i where a.almacen=b.codigo_almacen and b.compania = "+compania+" and is_bm = 'Y' and i.estado = 'A' and a.almacen=i.codigo_almacen and i.cod_articulo= bm.cod_articulo and b.compania=i.compania )  union all select distinct cod_articulo as codigo, upper(descripcion)||' [FARMACIA]' as descripcion from tbl_inv_articulo where estado = 'A' and venta_sino ='S' and compania = 5) aa where 1 = 1 "+appendFilter+"  order by aa.descripcion ";
    
    sql = "select aa.* from (select codigo, nvl(descripcion2, descripcion1) as descripcion from tbl_far_medicamentos) aa where 1 = 1 "+appendFilter+"  order by aa.descripcion ";
  
  } else if (fp.equalsIgnoreCase("medico")) {
    
    sql = "select aa.* from (select a.codigo, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre) || ' ' || a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) || '     ('||nvl(to_char(a.reg_medico),a.codigo)||')' as descripcion from tbl_adm_medico a where estado = 'A') aa where 1 = 1 "+appendFilter+"  order by aa.descripcion ";
    
  } else if (fp.equalsIgnoreCase("NUT")) {
    sql = " select aa.* from (select h.codigo||'-'||d.codigo as codigo, h.descripcion||' -> '||d.descripcion  descripcion from TBL_CDS_TIPO_DIETA h, tbl_cds_subtipo_dieta d where h.codigo = d.COD_TIPO_DIETA(+) order by h.codigo, d.codigo ) aa where 1 = 1 "+appendFilter;
    
  } else if (fp.equalsIgnoreCase("TRA")) {
  
    sql = " select aa.codigo, aa.descripcion from tbl_sal_tratamiento aa where aa.estado = 'A' "+appendFilter;
  } else if (fp.equalsIgnoreCase("VAR")) {
  
    sql = " select aa.* from (select h.codigo||'-'||d.codigo as codigo, h.descripcion||' -> '||d.descripcion  descripcion from TBL_CDS_ORDENMEDICA_VARIOS h, tbl_cds_om_varios_subtipo d where h.codigo = d.cod_tipo_ordenvarios(+) order by h.codigo, d.codigo ) aa where 1 = 1 "+appendFilter;
  } else if (fp.equalsIgnoreCase("INT")) {
	  
	  sql = " select aa.* from (SELECT c.codigo, c.descripcion FROM tbl_adm_especialidad_medica c ORDER BY 2 ) aa where 1 = 1 "+appendFilter;
  }
	
	if (!fp.trim().equals("")) {
    al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("select count(*) from ("+sql+")");
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
  
  String jsContext = "window.opener.";
  if (context.equalsIgnoreCase("preventPopupFrame")) jsContext = "parent.";
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Orderset - '+document.title;

function getMain(formx)
{
	formx.cds.value = document.search00.cds.value;
	formx.catCode.value = document.search00.catCode.value;
	return true;
}

function setValues(i){
	var cs = document.procedimiento.cs.value;
	var index = document.procedimiento.index.value;
		
  <% if (fp.equalsIgnoreCase("LIS") || fp.equalsIgnoreCase("RIS") || fp.equalsIgnoreCase("MED") || fp.equalsIgnoreCase("BDS") || fp.equalsIgnoreCase("NUT") || fp.equalsIgnoreCase("TRA") || fp.equalsIgnoreCase("VAR") || fp.equalsIgnoreCase("INT")){%>
       $("#ref_code<%=index%>", <%=jsContext%>document).val(eval('document.procedimiento.codigo'+i).value);
       $("#ref_name<%=index%>", <%=jsContext%>document).val(eval('document.procedimiento.descripcion'+i).value);
       
  <%} if (fp.equalsIgnoreCase("medico")){%>
       <%if(!index.equals("")){%>
          $("#med_code<%=index%>", <%=jsContext%>document).val(eval('document.procedimiento.codigo'+i).value);
          $("#med_name<%=index%>", <%=jsContext%>document).val(eval('document.procedimiento.descripcion'+i).value);
       <%} else if(!alSize.equals("0")) {%>
          for (z = 0; z < <%=alSize%>; z++) {
            $("#med_code"+z, <%=jsContext%>document).val(eval('document.procedimiento.codigo'+i).value);
            $("#med_name"+z, <%=jsContext%>document).val(eval('document.procedimiento.descripcion'+i).value);
          }
          
          $("#med_name", <%=jsContext%>document).val('');
       <%} else if (fg.equalsIgnoreCase("oset_activos")){%>
          $("#med_code", <%=jsContext%>document).val(eval('document.procedimiento.codigo'+i).value);
          $("#med_name", <%=jsContext%>document).val(eval('document.procedimiento.descripcion'+i).value);
       <%}%>
  <%} %>
	
  <%if(context.equalsIgnoreCase("preventPopupFrame")){%>
    <%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";
  <%}else{%>
    window.close();
  <%}%>
}

function doAction() {
  <% if(context.equalsIgnoreCase("preventPopupFrame")) { 
    if (al.size() == 0) {%><%=jsContext%>document.getElementById("preventPopupFrame").style.display="none";<%}
    else if (al.size() == 1) {%>setValues(0);<%}%>
  <%}%>
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction();">
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("cs",cs)%>
				<%=fb.hidden("pac_id",pac_id)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("codCita",codCita)%>
				<%=fb.hidden("fechaCita",fechaCita)%>
				<%=fb.hidden("tab",tab)%>
				<%=fb.hidden("context",context)%>
				<%=fb.hidden("al_size",alSize)%>
				<td width="40%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.intBox("codigo","",false,false,false,15)%>
				</td>
				<td width="60%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,70)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
				</tr>
			</table>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
					<%=fb.hidden("al_size",alSize)%>

					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
					<%=fb.hidden("al_size",alSize)%>
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
<%
fb = new FormBean("procedimiento","","post","");
%>
<%=fb.formStart()%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("cs",cs)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("codCita",codCita)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("context",context)%>
<%=fb.hidden("al_size",alSize)%>
			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="20%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="80%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
				</tr>
        <% for (int i=0; i<al.size(); i++) {
          CommonDataObject cdo = (CommonDataObject) al.get(i);
          String color = "TextRow02";
          if (i % 2 == 0) color = "TextRow01";
        %>
				<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
				<%=fb.hidden("descripcion"+i,cdo.getColValue("descripcion"))%>
				<%=fb.hidden("centro_servicio"+i,cdo.getColValue("centro_servicio"))%>
				<%=fb.hidden("centro_servicio_desc"+i,cdo.getColValue("centro_servicio_desc"))%>
				
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setValues(<%=i%>)" style="cursor:pointer">
					<td align="center"><%=cdo.getColValue("codigo")%></td>
					<td ><%=cdo.getColValue("descripcion")%></td>
				</tr>
				
      <%}%>
<%=fb.hidden("keySize",""+al.size())%>
<%=fb.formEnd()%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
					<%=fb.hidden("al_size",alSize)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
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
					<%=fb.hidden("fg",fg)%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("cs",cs)%>
					<%=fb.hidden("pac_id",pac_id)%>
					<%=fb.hidden("admision",admision)%>
					<%=fb.hidden("index",index)%>
					<%=fb.hidden("codCita",codCita)%>
					<%=fb.hidden("fechaCita",fechaCita)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("codigo",codigo)%>
					<%=fb.hidden("descripcion",descripcion)%>
					<%=fb.hidden("context",context)%>
					<%=fb.hidden("al_size",alSize)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

</body>
</html>
<%
}//GET
%>