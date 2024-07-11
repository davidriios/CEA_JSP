<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iMedi" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMedi" scope="session" class="java.util.Vector" />
<%
/**
==============================================================================
==============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500021") || SecMgr.checkAccess(session.getId(),"500022") || SecMgr.checkAccess(session.getId(),"500023") || SecMgr.checkAccess(session.getId(),"500024"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String tab = request.getParameter("tab");
String asiento = "";
String tomo = "";
String sigla = "";
String prov = "";

int mLastLineNo = 0;

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mLastLineNo") != null) mLastLineNo = Integer.parseInt(request.getParameter("mLastLineNo"));
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("asiento") != null && !request.getParameter("asiento").equals("")) asiento = request.getParameter("asiento");
if (request.getParameter("tomo") != null && !request.getParameter("tomo").equals("")) tomo = request.getParameter("tomo");
if (request.getParameter("sigla") != null && !request.getParameter("sigla").equals("")) sigla = request.getParameter("sigla");
if (request.getParameter("prov") != null && !request.getParameter("prov").equals("")) prov = request.getParameter("prov");

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

  if (request.getParameter("medicoId") != null)
  {
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("medicoId").toUpperCase()+"%'";
    searchOn = "a.codigo";
    searchVal = request.getParameter("medicoId");
    searchType = "1";
    searchDisp = "Código";
  }
  else if (request.getParameter("medicoDesc") != null)
  {
		appendFilter += " and upper(a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))) like '%"+request.getParameter("medicoDesc").toUpperCase()+"%'";
    searchOn = "a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada))";
    searchVal = request.getParameter("medicoDesc");
    searchType = "1";
    searchDisp = "Descripción";
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

	if (fp.equalsIgnoreCase("doctoresResid"))
	{
	   sql = "SELECT a.codigo||'-'||decode(c.codigo,null,'0',c.codigo) as medicEspec, a.codigo as med_ref_id, a.primer_nombre||decode(a.segundo_nombre,null,'',' '||a.segundo_nombre)||' '||a.primer_apellido||decode(a.segundo_apellido,null,'',' '||a.segundo_apellido)||decode(a.sexo,'F',decode(a.apellido_de_casada,null,'',' '||a.apellido_de_casada)) as med_ref_nombre, a.telefono as med_ref_tel, decode(c.codigo,null,'0',c.codigo) as med_espec_ini, decode(c.descripcion,null,'NO TIENE',c.descripcion) as med_especialid FROM tbl_adm_medico a, tbl_adm_medico_especialidad b, tbl_adm_especialidad_medica c where a.codigo=b.medico(+) and b.especialidad=c.codigo(+)"+appendFilter+" order by c.descripcion";

		al = SQLMgr.getDataList("SELECT * FROM (SELECT rownum as rn, a.* FROM ("+sql+") a) WHERE rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("SELECT count(*) FROM tbl_adm_medico a, tbl_adm_medico_especialidad b, tbl_adm_especialidad_medica c where a.codigo=b.medico(+) and b.secuencia(+)=1 and b.especialidad=c.codigo(+) "+appendFilter);
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
document.title = 'M&eacute;dicos - '+document.title;
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MÉDICOS Y SUS ESPECILIDADES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->		
			<table width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextFilter">		
					<%
					fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("prov",prov)%>
					<%=fb.hidden("mLastLineNo",""+mLastLineNo)%>
					<td width="50%"><cellbytelabel>Id M&eacute;dico</cellbytelabel>
					<%=fb.textBox("medicoId","",false,false,false,30)%>
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
					<%=fb.hidden("tab",tab)%>
					<%=fb.hidden("asiento",asiento)%>
					<%=fb.hidden("tomo",tomo)%>
					<%=fb.hidden("sigla",sigla)%>
					<%=fb.hidden("prov",prov)%>
					<%=fb.hidden("mLastLineNo",""+mLastLineNo)%>
					<td width="50%"><cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("medicoDesc","",false,false,false,40)%>
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
fb = new FormBean("tipohabitacion",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("tab",tab)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("mLastLineNo",""+mLastLineNo)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
	
<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
	
			<table align="center" width="100%" cellpadding="1" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="35%"><cellbytelabel>Especialidad</cellbytelabel></td>
					<td width="10%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
					<td width="35%"><cellbytelabel>Nombre</cellbytelabel></td>
					<td width="10%"><cellbytelabel>Tel</cellbytelabel></td>
					<td width="10%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los tipos de habitación listados!")%></td>
				</tr>				
				<%
				for (int i=0; i<al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("medicEspec"+i,cdo.getColValue("medicEspec"))%>
				<%=fb.hidden("codigo"+i,cdo.getColValue("med_ref_id"))%>
				<%=fb.hidden("nombre"+i,cdo.getColValue("med_ref_nombre"))%>
				<%=fb.hidden("especialidad"+i,cdo.getColValue("med_espec_ini"))%>
				<%=fb.hidden("especialidadDesc"+i,cdo.getColValue("med_especialid"))%>
				<%=fb.hidden("telefono"+i,cdo.getColValue("med_ref_tel"))%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td><%=cdo.getColValue("med_especialid")%></td>
					<td><%=cdo.getColValue("med_ref_id")%></td>
					<td><%=cdo.getColValue("med_ref_nombre")%></td>
					<td><%=cdo.getColValue("med_ref_tel")%></td>
					<td align="center"><%=(vMedi.contains(cdo.getColValue("medicEspec")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("medicEspec"),false,false)%></td>
				</tr>
				<%
				}
				%>
			</table>
	
<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->
	
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
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
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
	mLastLineNo = Integer.parseInt(request.getParameter("mLastLineNo"));
	
	for (int i=0; i<size; i++)
	{
	    
		if (request.getParameter("check"+i) != null)
		{
			CommonDataObject cdo = new CommonDataObject();
            
			cdo.addColValue("medicEspec",request.getParameter("medicEspec"+i));
			cdo.addColValue("med_ref_id",request.getParameter("codigo"+i));
			cdo.addColValue("med_ref_nombre",request.getParameter("nombre"+i));
			cdo.addColValue("med_espec_ini",request.getParameter("especialidad"+i));
			cdo.addColValue("med_especialid",request.getParameter("especialidadDesc"+i));
			cdo.addColValue("med_ref_tel",request.getParameter("telefono"+i));

			mLastLineNo++;
             
			String key = "";
			if (mLastLineNo < 10) key = "00"+mLastLineNo;
			else if (mLastLineNo < 100) key = "0"+mLastLineNo;
			else key = ""+mLastLineNo;
			cdo.addColValue("key",key);

			try
			{
				iMedi.put(key,cdo);
				vMedi.add(request.getParameter("medicEspec"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&asiento="+asiento+"&tomo="+tomo+"&sigla="+sigla+"&prov="+prov+"&tab="+tab+"&mLastLineNo="+mLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&asiento="+asiento+"&tomo="+tomo+"&sigla="+sigla+"&prov="+prov+"&tab="+tab+"&mLastLineNo="+mLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery"));
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
	if (fp.equalsIgnoreCase("doctoresResid"))
	{
%>
	window.opener.location = '../residencial/residente_config.jsp?change=1&mode=<%=mode%>&tab=<%=tab%>&prov=<%=prov%>&asiento=<%=asiento%>&tomo=<%=tomo%>&sigla=<%=sigla%>&mLastLineNo=<%=mLastLineNo%>';
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