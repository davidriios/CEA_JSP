<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.convenio.CoberturaCentro"%>
<%@ page import="issi.convenio.ExclusionCentro"%>
<%@ page import="issi.admision.DetalleCoberturaConvenio"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iTServ" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vTServ" scope="session" class="java.util.Vector" />
<jsp:useBean id="iCobCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCobCD" scope="session" class="java.util.Vector" />
<jsp:useBean id="iExclCD" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vExclCD" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);%><%
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100031") || SecMgr.checkAccess(session.getId(),"100032") || SecMgr.checkAccess(session.getId(),"100033") || SecMgr.checkAccess(session.getId(),"100034"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
int tServLastLineNo = 0;
int userLastLineNo = 0;
int tAdmLastLineNo = 0;
int pamLastLineNo = 0;
int procLastLineNo = 0;
int docLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("tServLastLineNo") != null) tServLastLineNo = Integer.parseInt(request.getParameter("tServLastLineNo"));
if (request.getParameter("userLastLineNo") != null) userLastLineNo = Integer.parseInt(request.getParameter("userLastLineNo"));
if (request.getParameter("tAdmLastLineNo") != null) tAdmLastLineNo = Integer.parseInt(request.getParameter("tAdmLastLineNo"));
if (request.getParameter("pamLastLineNo") != null) pamLastLineNo = Integer.parseInt(request.getParameter("pamLastLineNo"));
if (request.getParameter("procLastLineNo") != null) procLastLineNo = Integer.parseInt(request.getParameter("procLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));

//convenio_cobertura_centro, convenio_exclusion_centro, pm_convenio_cobertura_centro
String tab = request.getParameter("tab");
String cTab = request.getParameter("cTab");
String empresa = request.getParameter("empresa");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipoPoliza");
String tipoPlan = request.getParameter("tipoPlan");
String planNo = request.getParameter("planNo");
String categoriaAdm = request.getParameter("categoriaAdm");
String tipoAdm = request.getParameter("tipoAdm");
String clasifAdm = request.getParameter("clasifAdm");
String tipoCE = request.getParameter("tipoCE");
String ce = request.getParameter("ce");
String index = request.getParameter("index");
int ceCDLastLineNo = 0;
String centroServicio = request.getParameter("centroServicio");
//convenio solicitud de beneficio
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String secuencia_cob = request.getParameter("secuencia_cob");
String secuencia_sol1= request.getParameter("secuencia_sol1");
String solicitud = request.getParameter("solicitud");

if (mode == null) mode = "add";
if (id == null) id = "";
if (tab == null) tab = "";
if (cTab == null) cTab = "";
if (empresa == null) empresa = "";
if (secuencia == null) secuencia = "";
if (tipoPoliza == null) tipoPoliza = "";
if (tipoPlan == null) tipoPlan = "";
if (planNo == null) planNo = "";
if (categoriaAdm == null) categoriaAdm = "";
if (tipoAdm == null) tipoAdm = "";
if (clasifAdm == null) clasifAdm = "";
if (tipoCE == null) tipoCE = "";
if (ce == null) ce = "";
if (index == null) index = "";
if (request.getParameter("ceCDLastLineNo") != null) ceCDLastLineNo = Integer.parseInt(request.getParameter("ceCDLastLineNo"));
if (centroServicio == null) centroServicio = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
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

	if (request.getParameter("code") != null)
	{
		
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("code").toUpperCase()+"%'";

    searchOn = "a.codigo";
    searchVal = request.getParameter("code");
    searchType = "1";
    searchDisp = "Código";
	}
	else if (request.getParameter("name") != null)
	{
		appendFilter += " and upper(a.descripcion) like '%"+request.getParameter("name").toUpperCase()+"%'";

    searchOn = "a.descripcion";
    searchVal = request.getParameter("name");
    searchType = "1";
    searchDisp = "Nombre";
	}
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFromDate").equals("SVFD") && !request.getParameter("searchValToDate").equals("SVTD"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
			appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }

	if (fp.equalsIgnoreCase("cds_references") || fp.equalsIgnoreCase("MAPPING_CPT"))
	{
		sql = "select a.codigo as code, a.descripcion as name, a.compania from tbl_cds_tipo_servicio a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_cds_tipo_servicio a where a.compania="+(String) session.getAttribute("_companyId")+appendFilter);
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("pm_convenio_cobertura_centro") || fp.equalsIgnoreCase("convenio_exclusion_centro") || fp.equalsIgnoreCase("pm_convenio_exclusion_centro") || fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
		sql = "select a.codigo as code, a.descripcion as name from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo=b.tipo_servicio and b.centro_servicio="+centroServicio+appendFilter+" order by a.descripcion";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_cds_tipo_servicio a, tbl_cds_servicios_x_centros b where a.codigo=b.tipo_servicio and b.centro_servicio="+centroServicio+appendFilter);
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
<script language="javascript">
document.title = 'Tipo de Servicio - '+document.title;
function setTS(i){
 <%if(fp.equalsIgnoreCase("MAPPING_CPT")){%>
  $("#ts_code",window.opener.document).val($("#code"+i).val());
  $("#ts_desc",window.opener.document).val($("#name"+i).val());
  $("#hasChanged",window.opener.document).val("Y");
  window.close();
 <%}%> 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE TIPO DE SERVICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="1">
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
				<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
				<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
				<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
				<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("tab",tab)%>
				<%=fb.hidden("cTab",cTab)%>
				<%=fb.hidden("empresa",empresa)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("tipoPoliza",tipoPoliza)%>
				<%=fb.hidden("tipoPlan",tipoPlan)%>
				<%=fb.hidden("planNo",planNo)%>
				<%=fb.hidden("categoriaAdm",categoriaAdm)%>
				<%=fb.hidden("tipoAdm",tipoAdm)%>
				<%=fb.hidden("clasifAdm",clasifAdm)%>
				<%=fb.hidden("tipoCE",tipoCE)%>
				<%=fb.hidden("ce",ce)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
				<%=fb.hidden("centroServicio",centroServicio)%>
				<%=fb.hidden("solicitud",solicitud)%>
				<%=fb.hidden("secuencia_cob",secuencia_cob)%>
				<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("pac_id",pac_id)%>
				<%=fb.hidden("cod_pac",cod_pac)%>
				<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>

				<td width="50%">
					<cellbytelabel>C&oacute;digo</cellbytelabel>
					<%=fb.textBox("code","",false,false,false,30)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
				<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
				<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
				<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
				<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("tab",tab)%>
				<%=fb.hidden("cTab",cTab)%>
				<%=fb.hidden("empresa",empresa)%>
				<%=fb.hidden("secuencia",secuencia)%>
				<%=fb.hidden("tipoPoliza",tipoPoliza)%>
				<%=fb.hidden("tipoPlan",tipoPlan)%>
				<%=fb.hidden("planNo",planNo)%>
				<%=fb.hidden("categoriaAdm",categoriaAdm)%>
				<%=fb.hidden("tipoAdm",tipoAdm)%>
				<%=fb.hidden("clasifAdm",clasifAdm)%>
				<%=fb.hidden("tipoCE",tipoCE)%>
				<%=fb.hidden("ce",ce)%>
				<%=fb.hidden("index",index)%>
				<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
				<%=fb.hidden("centroServicio",centroServicio)%>
				<%=fb.hidden("solicitud",solicitud)%>
				<%=fb.hidden("secuencia_cob",secuencia_cob)%>
				<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
				<%=fb.hidden("admision",admision)%>
				<%=fb.hidden("pac_id",pac_id)%>
				<%=fb.hidden("cod_pac",cod_pac)%>
				<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>

				<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("name","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
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
<%
fb = new FormBean("tipoServicio",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("tServLastLineNo",""+tServLastLineNo)%>
<%=fb.hidden("userLastLineNo",""+userLastLineNo)%>
<%=fb.hidden("tAdmLastLineNo",""+tAdmLastLineNo)%>
<%=fb.hidden("pamLastLineNo",""+pamLastLineNo)%>
<%=fb.hidden("procLastLineNo",""+procLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("cTab",cTab)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("tipoPoliza",tipoPoliza)%>
<%=fb.hidden("tipoPlan",tipoPlan)%>
<%=fb.hidden("planNo",planNo)%>
<%=fb.hidden("categoriaAdm",categoriaAdm)%>
<%=fb.hidden("tipoAdm",tipoAdm)%>
<%=fb.hidden("clasifAdm",clasifAdm)%>
<%=fb.hidden("tipoCE",tipoCE)%>
<%=fb.hidden("ce",ce)%>
<%=fb.hidden("index",index)%>
<%=fb.hidden("ceCDLastLineNo",""+ceCDLastLineNo)%>
<%=fb.hidden("centroServicio",centroServicio)%>
<%=fb.hidden("solicitud",solicitud)%>
<%=fb.hidden("secuencia_cob",secuencia_cob)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("secuencia_sol1",secuencia_sol1)%>

	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%if(!fp.equals("MAPPING_CPT")){%>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						<%}%>	
					</td>
				</tr>
			</table>
		</td>
	</tr>
	
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>	

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader" align="center">
		<td width="30%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
		<td width="60%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
		<td width="10%">
		<%if(!fp.equals("MAPPING_CPT")){%><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los tipos de servicios listados!")%><%}%></td>
	</tr>
<%
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("code"+i,cdo.getColValue("code"))%>
		<%=fb.hidden("name"+i,cdo.getColValue("name"))%>
		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="setTS(<%=i%>)">
			<td><%=cdo.getColValue("code")%></td>
			<td class="pointer"><%=cdo.getColValue("name")%></td>
			<td align="center">
			<%if(!fp.equals("MAPPING_CPT")){%>
			<%=((fp.equalsIgnoreCase("cds_references") && vTServ.contains(cdo.getColValue("code"))) || ( (fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("pm_convenio_cobertura_centro")) && vCobCD.contains(cdo.getColValue("code"))) || (fp.equalsIgnoreCase("convenio_cobertura_solicitud") && vCobCD.contains(cdo.getColValue("code")))|| ( (fp.equalsIgnoreCase("convenio_exclusion_centro") || fp.equalsIgnoreCase("pm_convenio_exclusion_centro") ) && vExclCD.contains(cdo.getColValue("code"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("code"),false,false)%>
			<%}%>
			</td>
		</tr>
<%
}
%>				
</table>
		</td>
	</tr>		
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
					<%if(!fp.equals("MAPPING_CPT")){%>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						<%}%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	if (fp.equalsIgnoreCase("cds_references"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CommonDataObject cdo = new CommonDataObject();
	
				cdo.addColValue("tipoServicio",request.getParameter("code"+i));
				cdo.addColValue("tipoServicioDesc",request.getParameter("name"+i));
				tServLastLineNo++;
	
				String key = "";
				if (tServLastLineNo < 10) key = "00"+tServLastLineNo;
				else if (tServLastLineNo < 100) key = "0"+tServLastLineNo;
				else key = ""+tServLastLineNo;
				cdo.addColValue("key",key);
		
				try
				{
					iTServ.put(key, cdo);
					vTServ.add(cdo.getColValue("tipoServicio"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}// checked
		}//for
	}//cds_references 
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro") || fp.equalsIgnoreCase("pm_convenio_cobertura_centro"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				CoberturaCentro cc = new CoberturaCentro();

				cc.setTipoServicio(request.getParameter("code"+i));
				cc.setTipoServicioDesc(request.getParameter("name"+i));
				ceCDLastLineNo++;
	
				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				cc.setKey(key);

				try
				{
					iCobCD.put(cc.getKey(),cc);
					vCobCD.add(cc.getTipoServicio());
				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}// checked
		}//for
	}//convenio_cobertura_centro, pm_convenio_cobertura_centro,
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				DetalleCoberturaConvenio cc = new DetalleCoberturaConvenio();
				cc.setSecuencia("0");
				cc.setTipoServicio(request.getParameter("code"+i));
				cc.setDescripcion(request.getParameter("name"+i));
				ceCDLastLineNo++;
	
				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				cc.setKey(key);

				try
				{
					iCobCD.put(cc.getKey(),cc);
					vCobCD.add(cc.getTipoServicio());
				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}// checked
		}//for
	}//convenio_cobertura_solicitud
	else if (fp.equalsIgnoreCase("convenio_exclusion_centro") ||fp.equalsIgnoreCase("pm_convenio_exclusion_centro") )
	{
		for (int i=0; i<size; i++)
		{
			if (request.getParameter("check"+i) != null)
			{
				ExclusionCentro ec = new ExclusionCentro();

				ec.setTipoServicio(request.getParameter("code"+i));
				ec.setTipoServicioDesc(request.getParameter("name"+i));
				ceCDLastLineNo++;
	
				String key = "";
				if (ceCDLastLineNo < 10) key = "00"+ceCDLastLineNo;
				else if (ceCDLastLineNo < 100) key = "0"+ceCDLastLineNo;
				else key = ""+ceCDLastLineNo;
				ec.setKey(key);

				try
				{
					iExclCD.put(ec.getKey(),ec);
					vExclCD.add(ec.getTipoServicio());
				}
				catch(Exception ex)
				{
					System.err.println(ex.getMessage());
				}
			}// checked
		}//for
	}//convenio_exclusion_centro, pm_convenio_exclusion_centro

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&centroServicio="+centroServicio+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&id="+id+"&tServLastLineNo="+tServLastLineNo+"&userLastLineNo="+userLastLineNo+"&tAdmLastLineNo="+tAdmLastLineNo+"&pamLastLineNo="+pamLastLineNo+"&procLastLineNo="+procLastLineNo+"&docLastLineNo="+docLastLineNo+"&tab="+tab+"&cTab="+cTab+"&empresa="+empresa+"&secuencia="+secuencia+"&tipoPoliza="+tipoPoliza+"&tipoPlan="+tipoPlan+"&planNo="+planNo+"&categoriaAdm="+categoriaAdm+"&tipoAdm="+tipoAdm+"&clasifAdm="+clasifAdm+"&tipoCE="+tipoCE+"&ce="+ce+"&index="+index+"&ceCDLastLineNo="+ceCDLastLineNo+"&centroServicio="+centroServicio+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&pac_id="+request.getParameter("pac_id")+"&cod_pac="+request.getParameter("cod_pac")+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&admision="+request.getParameter("admision")+"&solicitud="+request.getParameter("solicitud")+"&secuencia_sol1="+request.getParameter("secuencia_sol1")+"&secuencia_cob="+request.getParameter("secuencia_cob"));
		return;
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("cds_references"))
	{
%>
	window.opener.location = '../admin/reg_cds_references.jsp?change=1&tab=0&mode=<%=mode%>&id=<%=id%>&tServLastLineNo=<%=tServLastLineNo%>&userLastLineNo=<%=userLastLineNo%>&tAdmLastLineNo=<%=tAdmLastLineNo%>&pamLastLineNo=<%=pamLastLineNo%>&procLastLineNo=<%=procLastLineNo%>&docLastLineNo=<%=docLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_centro"))
	{
%>
	window.opener.location = '../convenio/convenio_cobertura_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&index=<%=index%>&cobCDLastLineNo=<%=ceCDLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_cobertura_centro"))
	{
%>	 
        window.opener.location = 	'../planmedico/pm_convenio_cobertura_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&index=<%=index%>&cobCDLastLineNo=<%=ceCDLastLineNo%>';
<%	}
	else if (fp.equalsIgnoreCase("convenio_cobertura_solicitud"))
	{
%>
	window.opener.location = '../admision/detalle_cobertura_centro.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&tipoCobertura=<%=tipoCE%>&cobertura=<%=ce%>&index=<%=index%>&cobCDLastLineNo=<%=ceCDLastLineNo%>&secuencia_cob=<%=secuencia_cob%>&secuencia_sol1=<%=secuencia_sol1%>&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&solicitud=<%=solicitud%>&admision=<%=admision%>&fecha_nacimiento=<%=fecha_nacimiento%>&cds=<%=centroServicio%>';
<%
	}
	else if (fp.equalsIgnoreCase("convenio_exclusion_centro"))
	{
%>
	window.opener.location = '../convenio/convenio_exclusion_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&index=<%=index%>&exclCDLastLineNo=<%=ceCDLastLineNo%>';
<%
	}
	else if (fp.equalsIgnoreCase("pm_convenio_exclusion_centro"))
	{
%>	
        window.opener.location = '../planmedico/pm_convenio_exclusion_cendet.jsp?change=1&tab=<%=tab%>&cTab=<%=cTab%>&mode=<%=mode%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipoPoliza=<%=tipoPoliza%>&tipoPlan=<%=tipoPlan%>&planNo=<%=planNo%>&categoriaAdm=<%=categoriaAdm%>&tipoAdm=<%=tipoAdm%>&clasifAdm=<%=clasifAdm%>&tipoExclusion=<%=tipoCE%>&exclusion=<%=ce%>&index=<%=index%>&exclCDLastLineNo=<%=ceCDLastLineNo%>';
<%	
        }
%>
	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>