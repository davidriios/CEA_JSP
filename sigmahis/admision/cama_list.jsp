<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
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
String sql = "";
String appendFilter = "", estado = "", habitacion = "", cama = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String compania = (String) session.getAttribute("_companyId");

if (request.getParameter("mode") == null) mode = "add";
if (cds == null) cds = "";

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

	if (request.getParameter("cds") != null && !request.getParameter("cds").equals(""))
	{
		appendFilter += " and  a.unidad_admin = "+request.getParameter("cds")+"";
	    cds = request.getParameter("cds");
	}
	if (request.getParameter("estado") != null && !request.getParameter("estado").equals(""))
	{
		appendFilter += " and c.estado_cama = '"+request.getParameter("estado")+"'";
	    estado = request.getParameter("estado");
	}
	if (request.getParameter("cama") != null && !request.getParameter("cama").trim().equals(""))
	{
		appendFilter += " and upper(c.codigo) like '%"+request.getParameter("cama").trim().toUpperCase()+"%'";
	    cama = request.getParameter("cama");
	}
	if (request.getParameter("habitacion") != null && !request.getParameter("habitacion").trim().equals(""))
	{
		appendFilter += " and upper(a.codigo) like '%"+request.getParameter("habitacion").trim().toUpperCase()+"%'";
	    habitacion = request.getParameter("habitacion");
	}


		sql = "select  a.unidad_admin as unidadadmin_hab, b.descripcion as unidadname_hab,a.codigo cod_hab, a.descripcion desc_hab, a.estado_habitacion as estadohab, a.accesorios accesesorios_hab, a.quirofano as quirofano, a.centro_servicio other2, a.comments , /*camas*/  c.codigo codigo_cama, nvl(c.descripcion,'CAMA NO DESCRITA') desc_cama, c.estado_cama, decode(c.estado_cama,'M','MANTENIMIENTO', 'U','EN USO', 'D','DISPONIBLE', 'I','INACTIVO', 'T','TRAMITE') estado_cama_dsp, c.tipo_hab as tipohab, (select descripcion from tbl_sal_tipo_habitacion where codigo = c.tipo_hab and compania = c.compania) tipo_hab_name, (select categoria_hab from tbl_sal_tipo_habitacion where codigo = c.tipo_hab and compania = c.compania) cathab, nvl((select precio from tbl_sal_tipo_habitacion where codigo = c.tipo_hab and compania = c.compania),0) precio, c.extension ext_cama from tbl_sal_habitacion a, tbl_cds_centro_servicio b, tbl_sal_cama c where a.unidad_admin = b.codigo  and a.compania= "+compania+" and c.compania = "+compania+appendFilter+" and a.codigo = c.habitacion and a.compania = c.compania order by a.unidad_admin, a.codigo, c.estado_cama asc";


		//al = SQLMgr.getDataList(sql);
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);

		rowCount = al.size();


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

 $(document).ready(function(){
    jqTooltip();
    $("._jqHint").on("click", function(e){

        var i = getCurIndex();
        var codHab = $("#codHab"+i).val();
        var fromList = $("#codigoCama"+i).val();

        $("#urlState").val(window.location);

        //console.log($("#urlState").val());

        e.stopPropagation();

        if ( $("#editPermGranted"+i).length )
           abrir_ventana('../admision/habitacion_config.jsp?mode=edit&code='+codHab+'&fromList='+fromList);
    });


    $("#estado, #cds").change(function(e){
       $("#search00").submit();
    });

 });
 function setCurIndex(i){document.getElementById("curIndex").value = i;}
 function getCurIndex(){return document.getElementById("curIndex").value;}
 var xHeight=0;
function doAction(){xHeight=objHeight('_tblMain');resizeFrame();}
function resizeFrame(){resetFrameHeight(document.getElementById('_cMain'),xHeight,300);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE CAMA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0" id="_tblMain">
	<tr>
		<td>
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->
			<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextFilter">
        <%fb = new FormBean("search00",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<td colspan="2">
				<cellbytelabel>Sala o Secci&oacute;n</cellbytelabel>
				<%=fb.select(ConMgr.getConnection(),"select distinct a.codigo, a.descripcion, a.codigo from tbl_cds_centro_servicio a, tbl_sal_habitacion b where a.estado='A' and a.codigo=b.unidad_admin order by a.descripcion","cds",cds,"T")%>
				<cellbytelabel>Habitaci&oacute;n</cellbytelabel>&nbsp;
					<%=fb.textBox("habitacion",habitacion,false,false,false,10)%>
					<cellbytelabel>Cama</cellbytelabel>&nbsp;
					<%=fb.textBox("cama",cama,false,false,false,10)%>
					<cellbytelabel>Estado Cama</cellbytelabel>&nbsp;
					<%=fb.select("estado","D=DISPONIBLE,U=EN USO,I=INACTIVO,M=MANTENIMIENTO,T=TRAMITE",estado,"T")%>

				<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			</table>
<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
		</td>
	</tr>
  <tr class="TextRow02">
    <td>
       <div style="font-weight:bold; color:#000;">
         <span class="box-info box-info-d">&nbsp;</span><span class="box-info-text"><cellbytelabel>Disponible</cellbytelabel>&nbsp;&nbsp;</span>
         <span class="box-info box-info-u">&nbsp;</span><cellbytelabel>En uso</cellbytelabel>&nbsp;&nbsp;
         <span class="box-info box-info-i">&nbsp;</span><cellbytelabel>Inactivo</cellbytelabel>&nbsp;&nbsp;
         <span class="box-info box-info-bb">&nbsp;</span><cellbytelabel>Mantenimiento</cellbytelabel>&nbsp;&nbsp;
         <span class="box-info box-info-m">&nbsp;</span><cellbytelabel>Tr&aacute;mite</cellbytelabel>
       </div>
    </td>
  </tr>

	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
<%
fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
%>
<%=fb.formStart(true)%>
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
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("habitacion",habitacion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cama",cama)%>

    <td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
<%=fb.formEnd(true)%>
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
	<%=fb.hidden("cds",cds)%>
<%=fb.hidden("habitacion",habitacion)%>
<%=fb.hidden("estado",estado)%>
<%=fb.hidden("cama",cama)%>
    <td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
	<%=fb.formEnd(true)%>

				</tr>
			</table>
		</td>
	</tr>

 	<tr>
		<td class="TableLeftBorder TableRightBorder">

<div id="_cMain" class="Container">
<div id="_cContent" class="ContainerContent">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

<%fb = new FormBean("results",request.getContextPath()+request.getServletPath(),FormBean.POST);	%>
<%=fb.formStart()%>
<%=fb.hidden("curIndex","")%>
<%=fb.hidden("urlState","")%>
<%
String centroServicio = "", habitacionGrp = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);

	String cExtra = "";

	if (cdo.getColValue("estado_cama") != null){
    if ( cdo.getColValue("estado_cama").equals("D")){
       cExtra = "boxactive";
    }else
    if ( cdo.getColValue("estado_cama").equals("I")){
       cExtra = "boxinactive bgc-inactive";
    }else
    if ( cdo.getColValue("estado_cama").equals("M")){
       cExtra = "boxmantenimiento";
    }else
    if ( cdo.getColValue("estado_cama").equals("U")){
       cExtra = "boxenuso";
    }else
    if ( cdo.getColValue("estado_cama").equals("T")){
       cExtra = "boxtramite";
    }
	}

%>
				<%=fb.hidden("codHab"+i,cdo.getColValue("cod_hab"))%>
				<%=fb.hidden("descHab"+i,cdo.getColValue("desc_hab"))%>
				<%=fb.hidden("codigoCama"+i,cdo.getColValue("codigo_cama"))%>
				<%=fb.hidden("descCama"+i,cdo.getColValue("desc_cama"))%>
				<%=fb.hidden("estadoCama"+i,cdo.getColValue("estado_cama"))%>
				<%=fb.hidden("centroServicio"+i,cdo.getColValue("unidadadmin_hab"))%>
				<%=fb.hidden("centroServicioDesc"+i,cdo.getColValue("unidadname_hab"))%>
				<%=fb.hidden("precio"+i,cdo.getColValue("precio"))%>
<%
	if (!centroServicio.equalsIgnoreCase(cdo.getColValue("unidadadmin_hab")))
	{
%>
				<tr class="TextHeader01">
					<td colspan="5"><cellbytelabel>SALA O SECCION</cellbytelabel>: [<%=cdo.getColValue("unidadadmin_hab")%>] <%=cdo.getColValue("unidadname_hab")%></td>
				</tr>
		<%if(i!=0){%>
		  </td>
		</tr>
		<%}%>
<%
	}
%>

				<%
          if (!habitacionGrp.equalsIgnoreCase(cdo.getColValue("cod_hab")))
          {
        %>
           <tr class="TextHeader02">
              <td colspan="5"><cellbytelabel>HABITACION</cellbytelabel>: [<%=cdo.getColValue("cod_hab")%>] <%=cdo.getColValue("desc_hab")%></td>
            </tr>
				
				<tr class="">
				<td>
        <%
          }
        %>

			<!--<div class="box <%//=cExtra%> _jqHint" hintMsg="<%//=cdo.getColValue("desc_cama")%><br />Ext.: <%//=cdo.getColValue("ext_cama")%><br /><%//=cdo.getColValue("estado_cama_dsp")%>" onClick="javascript:setCurIndex('<%//=i%>')">
				<div class="camaimg">&nbsp;</div>
				  <span class="text">
                     <%//=cdo.getColValue("codigo_cama")%>
				  </span>
				  <span class="price">
                    $<%//=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%>
				  </span>
		    </div>-->
            
                <div class="box _jqHint" style="border: #000 solid 1px" hintMsg="<%=cdo.getColValue("desc_cama")%><br />Ext.: <%=cdo.getColValue("ext_cama")%><br /><%=cdo.getColValue("estado_cama_dsp")%>">
                  <div style=" text-align: center;">
                   <%=cdo.getColValue("codigo_cama")%>
                  </div>
                  
                  <div class="<%=cExtra%>">
                  </div>
                  
                  <div style=" text-align: center;">
                   $<%=CmnMgr.getFormattedDecimal(cdo.getColValue("precio"))%>
                  </div>
                </div>

				<authtype type='4'>
				  <%=fb.hidden("editPermGranted"+i,"y")%>
				</authtype>

<%
	centroServicio = cdo.getColValue("unidadadmin_hab");
	habitacionGrp = cdo.getColValue("cod_hab");
}
%>			</td>
          </tr>
		<%=fb.formEnd(true)%>

			</table>
		</div>
	</div>
		</td>
	</tr>
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
				<%=fb.hidden("cds",cds)%>
        <%=fb.hidden("habitacion",habitacion)%>
        <%=fb.hidden("estado",estado)%>
        <%=fb.hidden("cama",cama)%>
            <td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
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
        <%=fb.hidden("cds",cds)%>
        <%=fb.hidden("habitacion",habitacion)%>
        <%=fb.hidden("estado",estado)%>
        <%=fb.hidden("cama",cama)%>
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
}
%>
