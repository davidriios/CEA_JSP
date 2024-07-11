<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCama" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCama" scope="session" class="java.util.Vector" />
<jsp:useBean id="vCamaNew" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"100027") || SecMgr.checkAccess(session.getId(),"100028") || SecMgr.checkAccess(session.getId(),"100029") || SecMgr.checkAccess(session.getId(),"100030"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
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
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fromNewView = request.getParameter("from_new_view");
String fechaNacimiento = request.getParameter("fecha_nacimiento");
String codigoPaciente = request.getParameter("codigo_paciente");

if (fromNewView == null) fromNewView = "";
if (fechaNacimiento == null) fechaNacimiento = "";
if (codigoPaciente == null) codigoPaciente = "";

int camaLastLineNo = 0;
int diagLastLineNo = 0;
int docLastLineNo = 0;
int benLastLineNo = 0;
int respLastLineNo = 0;
String cds = request.getParameter("cds");

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("camaLastLineNo") != null) camaLastLineNo = Integer.parseInt(request.getParameter("camaLastLineNo"));
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));
if (request.getParameter("benLastLineNo") != null) benLastLineNo = Integer.parseInt(request.getParameter("benLastLineNo"));
if (request.getParameter("respLastLineNo") != null) respLastLineNo = Integer.parseInt(request.getParameter("respLastLineNo"));
if (cds == null) cds = "";
if (!cds.equals("")) appendFilter = " and c.codigo="+cds;

if (request.getMethod().equalsIgnoreCase("GET"))
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

	if (request.getParameter("habitacion") != null)
	{
		appendFilter += " and upper(a.habitacion) like '%"+request.getParameter("habitacion").toUpperCase()+"%'";

    searchOn = "a.habitacion";
    searchVal = request.getParameter("habitacion");
    searchType = "1";
    searchDisp = "Habitación";
	}
	else if (request.getParameter("cama") != null)
	{
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("cama").toUpperCase()+"%'";

    searchOn = "a.codigo";
    searchVal = request.getParameter("cama");
    searchType = "1";
    searchDisp = "Cama";
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

	if (fp.equalsIgnoreCase("admision") || fp.equalsIgnoreCase("admision_new"))
	{
		sql = "select a.habitacion, a.codigo as cama, a.estado_cama as estado, b.unidad_admin as centroServicio, c.descripcion as centroServicioDesc, d.precio, d.descripcion||' - '||decode(d.categoria_hab,'P','PRIVADA','S','SEMI-PRIVADA','O','OTROS','E','ECONOMICA','T','SUITE','Q','QUIROFANO','C','COMPARTIDA') as habitacionDesc,b.descripcion from tbl_sal_cama a, tbl_sal_habitacion b, tbl_cds_centro_servicio c, tbl_sal_tipo_habitacion d where a.compania=b.compania and a.habitacion=b.codigo and b.unidad_admin=c.codigo and a.compania=d.compania and a.tipo_hab=d.codigo and a.estado_cama='D' and b.estado_habitacion!='I' and b.compania="+(String) session.getAttribute("_companyId")+appendFilter+" order by c.descripcion, a.codigo";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from tbl_sal_cama a, tbl_sal_habitacion b, tbl_cds_centro_servicio c, tbl_sal_tipo_habitacion d where a.compania=b.compania and a.habitacion=b.codigo and b.unidad_admin=c.codigo and a.compania=d.compania and a.tipo_hab=d.codigo and a.estado_cama='D' and b.estado_habitacion!='I' and b.compania="+(String) session.getAttribute("_companyId")+appendFilter);
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
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Cama - '+document.title;

function getMain(formx)
{
	formx.cds.value = document.search00.cds.value;
	return true;
}
 $(document).ready(function(){
    jqTooltip();
    
    $(".box").on("click", function(e){
        var i = getCurIndex();
		var cama = $("#cama"+i).val();
		var hab = $("#habitacion"+i).val();
        if ( $("#check"+i).length > 0 ){
           $("#check"+i).attr("checked",true);
           
           if ( $("#check"+i).is(":checked") == true ){
		      avisarCAUT(cama,hab);
              $("#check"+i)[0].onclick();
           }
           
        }
    });
    
 });
 function setCurIndex(i){document.getElementById("curIndex").value = i;}
 function getCurIndex(){return document.getElementById("curIndex").value;}
 function avisarCAUT(cama,hab){
  var tot =  getDBData("<%=request.getContextPath()%>","count(*) tot ","tbl_sal_cargos_automaticos","cama = '"+cama+"' and habitacion = '"+hab+"' ","");
  if (tot > 0) alert("Esta cama tiene configurada "+tot+" cargo"+(tot > 1?"s":"")+" automático"+(tot > 1?"s":""));
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CAMA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextFilter">
<%
fb = new FormBean("search00",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
				<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
					<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
				<td colspan="2">
				<cellbytelabel>Sala o Secci&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select distinct a.codigo, a.descripcion, a.codigo from tbl_cds_centro_servicio a, tbl_sal_habitacion b where a.estado='A' and a.codigo=b.unidad_admin order by a.descripcion","cds",cds,"T")%>
				<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>		
			</tr>
			<tr class="TextFilter">
		
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath(),fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
				<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<%=fb.hidden("cds","").replaceAll(" id=\"cds\"","")%>
					<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
				<td width="50%">
					<cellbytelabel>Habitaci&oacute;n</cellbytelabel>
					<%=fb.textBox("habitacion","",false,false,false,10)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
<%
fb = new FormBean("search02",request.getContextPath()+request.getServletPath(),fb.GET,"onSubmit=\"javascript:return(getMain(this))\"");
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
				<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
				<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
				<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
				<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
				<%=fb.hidden("cds","").replaceAll(" id=\"cds\"","")%>
					<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
				<td width="50%">
					<cellbytelabel>Cama</cellbytelabel>
					<%=fb.textBox("cama","",false,false,false,10)%>
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
fb = new FormBean("centroServicio",request.getContextPath()+request.getServletPath(),FormBean.POST);
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
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("camaLastLineNo",""+camaLastLineNo)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%=fb.hidden("benLastLineNo",""+benLastLineNo)%>
<%=fb.hidden("respLastLineNo",""+respLastLineNo)%>
<%=fb.hidden("cds",cds).replaceAll(" id=\"cds\"","")%>
	<%=fb.hidden("fecha_nacimiento",fechaNacimiento)%>
	<%=fb.hidden("codigo_paciente", codigoPaciente)%>
	<%=fb.hidden("from_new_view",fromNewView)%>
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

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
		
	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				
				<%=fb.hidden("curIndex","")%>
<%
String centroServicio = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("habitacion"+i,cdo.getColValue("habitacion"))%>
				<%=fb.hidden("cama"+i,cdo.getColValue("cama"))%>
				<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
				<%=fb.hidden("centroServicio"+i,cdo.getColValue("centroServicio"))%>
				<%=fb.hidden("centroServicioDesc"+i,cdo.getColValue("centroServicioDesc"))%>
				<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
				<%=fb.hidden("habitacionDesc"+i,cdo.getColValue("habitacionDesc"))%>
<%
	if (!centroServicio.equalsIgnoreCase(cdo.getColValue("centroServicio")))
	{
%>
				<tr class="TextHeader01">
					<td colspan="5"><cellbytelabel>SALA O SECCION</cellbytelabel>: [<%=cdo.getColValue("centroServicio")%>] <%=cdo.getColValue("centroServicioDesc")%></td>
				</tr>
				
				<tr class="">
				<td>
<%
	}
%>
			<div style="border: #000 solid 1px" class="box _jqHint" hintMsg="Habitaci&oacute;n: [<%=cdo.getColValue("habitacion")%>] <%=cdo.getColValue("descripcion")%>" onClick="javascript:setCurIndex('<%=i%>')">
				  <div style=" text-align: center;">
                    <%=cdo.getColValue("cama")%>
				  </div>
				  <div class="boxactive">
                  </div>
                  
                  <div style=" text-align: center;">
                   $<%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%>
                  </div>
				</div>
				
				<span style="display:none;">
				  <%=(vCama.contains(cdo.getColValue("habitacion")+"-"+cdo.getColValue("cama")))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("habitacion")+"-"+cdo.getColValue("cama"),false,false,null,null,"onClick=\"javascript:document."+fb.getFormName()+".submit();\"")%>
				</span>
				
<%
	centroServicio = cdo.getColValue("centroServicio");
}
%>			</td>
          </tr>
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
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
	if (fp.equalsIgnoreCase("admision_new")) camaLastLineNo = iCama.size();
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			Admision obj = new Admision();

			obj.setHabitacion(request.getParameter("habitacion"+i));
			obj.setCama(request.getParameter("cama"+i));
			obj.setCentroServicio(request.getParameter("centroServicio"+i));
			obj.setCentroServicioDesc(request.getParameter("centroServicioDesc"+i));
			obj.setPrecio(request.getParameter("precio"+i));
			obj.setHabitacionDesc(request.getParameter("habitacionDesc"+i));
			obj.setCodigo("0");
			obj.setFechaInicio(cDateTime.substring(0,10));
			obj.setHoraInicio(cDateTime.substring(11));
			obj.setCasoEspecial("1");
			camaLastLineNo++;

			String key = "";
			if (camaLastLineNo < 10) key = "00"+camaLastLineNo;
			else if (camaLastLineNo < 100) key = "0"+camaLastLineNo;
			else key = ""+camaLastLineNo;
			obj.setKey(key);
	
			try
			{
				iCama.put(key, obj);
				vCama.add(obj.getHabitacion()+"-"+obj.getCama());
				vCamaNew.add(obj.getHabitacion()+"-"+obj.getCama());
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
		return;
	}
	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&camaLastLineNo="+camaLastLineNo+"&diagLastLineNo="+diagLastLineNo+"&docLastLineNo="+docLastLineNo+"&benLastLineNo="+benLastLineNo+"&respLastLineNo="+respLastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&from_new_view="+fromNewView+"&fecha_nacimiento="+fechaNacimiento+"&codigo_paciente="+codigoPaciente);
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
	if (fp.equalsIgnoreCase("admision"))
	{
%>
	window.opener.location = '../admision/admision_config.jsp?change=1&tab=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&from_new_view=<%=fromNewView%>';
<%
	} else if (fp.equalsIgnoreCase("admision_new"))
	{
%>
	window.opener.location = '../admision/admision_config_cama.jsp?change=1&tab=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&camaLastLineNo=<%=camaLastLineNo%>&diagLastLineNo=<%=diagLastLineNo%>&docLastLineNo=<%=docLastLineNo%>&benLastLineNo=<%=benLastLineNo%>&respLastLineNo=<%=respLastLineNo%>&loadInfo=S&fecha_nacimiento=<%=fechaNacimiento%>&codigo_paciente=<%=codigoPaciente%>&from_new_view=<%=fromNewView%>';
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