<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.AreaCorporal"%>
<%@ page import="issi.expediente.SubDetalleCara"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="ACMgr" scope="page" class="issi.expediente.AreaCorporalMgr" />
<jsp:useBean id="iSubDet" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
ACMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String tab = request.getParameter("tab");
String id = request.getParameter("id");
String caract = request.getParameter("caract");
String areaDesc = request.getParameter("area_desc");
String caractDesc = request.getParameter("caract_desc");
String codArea = request.getParameter("area");
String change = request.getParameter("change");
int detLastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (request.getParameter("detLastLineNo") != null) detLastLineNo = Integer.parseInt(request.getParameter("detLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET")){

    if (codArea == null) throw new Exception("El Factor del Examen Físico no es válido. Por favor intente nuevamente!");
    
    sql = "select count(*) from tbl_sal_sub_carat_areas_corp where cod_area_corp = "+codArea+" and cod_caract = "+caract;
    int totSubDet = CmnMgr.getCount(sql);
    
    System.out.println("------------------------------------------------------------- change = "+change);
    System.out.println(sql);

    if (totSubDet > 0) mode = "edit";
    System.out.println("------------------------------------------------------------- mode = "+mode);
    
	if (mode.equalsIgnoreCase("add")){
		id = "0";
        if (change == null) iSubDet.clear();
	}
	else{
	
		if (change == null){
			iSubDet.clear();

			sql = "select codigo, cod_area_corp, cod_caract, descripcion, orden from tbl_sal_sub_carat_areas_corp where cod_area_corp = "+codArea+" and cod_caract = "+caract+" order by 1";
			al = sbb.getBeanList(ConMgr.getConnection(), sql, SubDetalleCara.class);

			detLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++){
				SubDetalleCara det = (SubDetalleCara) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				iSubDet.put(key,det);
			}
		}//change is null
	}//edit mode
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title="Factores a Evaluar en el Examen Físico - Sub Detalle Características - "+document.title;

function doAction(){}

function removeDetail(k){
    removeItem('form2',k);
    form2BlockButtons(true);
    document.form2.submit();
}
debug("<%=sql%>")
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="1">
<tr>
	<td class="TableBorder">

		<table align="center" width="100%" cellpadding="1" cellspacing="1">

        <%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
        <%=fb.formStart(true)%>
        <%=fb.hidden("baction","")%>
        <%=fb.hidden("mode",mode)%>
        <%=fb.hidden("tab","2")%>
        <%=fb.hidden("id",id)%>
        <%=fb.hidden("caract",caract)%>
        <%=fb.hidden("caract_desc",caractDesc)%>
        <%=fb.hidden("area",codArea)%>
        <%=fb.hidden("area_desc",areaDesc)%>
        <%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
        <%=fb.hidden("size",""+iSubDet.size())%>

		<tr class="TextRow02">
			<td colspan="5">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>&Aacute;rea</cellbytelabel></td>
			<td colspan="4">[<%=codArea%>] <%=areaDesc%></td>
		</tr>
        <tr class="TextRow01">
			<td><cellbytelabel>Caracter&iacute;stica</cellbytelabel></td>
			<td colspan="4">[<%=caract%>] <%=caractDesc%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="80%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="3%">
                <%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
			</td>
		</tr>
<%
al = CmnMgr.reverseRecords(iSubDet);
for (int i = 1; i <= iSubDet.size(); i++)
{
	key = al.get(i - 1).toString();
	SubDetalleCara det = (SubDetalleCara) iSubDet.get(key);
	String displayDetalle = "";
	if (det.getStatus() != null && det.getStatus().equalsIgnoreCase("D")) displayDetalle = " style=\"display:none\"";
%>
		<%=fb.hidden("status"+i,det.getStatus())%>
		<%=fb.hidden("key"+i,det.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<tr class="TextRow01" align="center"<%=displayDetalle%>>
			<td><%=fb.intBox("codigo"+i,det.getCodigo(),false,false,true,5)%></td>
			<td><%=fb.textBox("descripcion"+i,det.getDescripcion(),true,false,false,85)%></td>
			<td>
              <%=fb.intBox("orden"+i, det.getOrden(),false,false,false,5)%>
            </td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeDetail("+i+")\"")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="5">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.hidePopWin(false)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>


	</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
    
    int size = Integer.parseInt(request.getParameter("size"));
    String itemRemoved = "";
    
    AreaCorporal area = new AreaCorporal();
    area.setCodigo(codArea);
    area.getSubDetalle().clear();
    
    for (int i=1; i<=size; i++) {
        SubDetalleCara det = new SubDetalleCara();

        det.setCodigo(request.getParameter("codigo"+i));
        det.setDescripcion(request.getParameter("descripcion"+i));
        det.setOrden(request.getParameter("orden"+i));
        det.setCodCaract(caract);
        det.setKey(request.getParameter("key"+i));

        if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
            itemRemoved = det.getKey();
            det.setStatus("D");
        }
        try{
            iSubDet.put(det.getKey(),det);
            area.addSubDetalle(det);
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
	}

    if (!itemRemoved.equals("")) {
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&id="+id+"&detLastLineNo="+detLastLineNo+"&caract="+caract+"&area="+codArea+"&caract_desc="+caractDesc+"&area_desc="+areaDesc);
        return;
    }

    if (baction != null && baction.equals("+")) {
        SubDetalleCara det = new SubDetalleCara();

        detLastLineNo++;
        if (detLastLineNo < 10) key = "00" + detLastLineNo;
        else if (detLastLineNo < 100) key = "0" + detLastLineNo;
        else key = "" + detLastLineNo;
        det.setCodigo("0");
        det.setCodCaract(caract);
        det.setKey(key);

        try{
            iSubDet.put(det.getKey(),det);
        }
        catch(Exception e)
        {
            System.err.println(e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&id="+id+"&detLastLineNo="+detLastLineNo+"&caract="+caract+"&area="+codArea+"&caract_desc="+caractDesc+"&area_desc="+areaDesc);
        return;
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    ACMgr.addSubDetalle(area);
    ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (ACMgr.getErrCode().equals("1"))
{
%>
	alert('<%=ACMgr.getErrMsg()%>');
<%
	if (tab.equals("0"))
	{
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/areacorporal_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/areacorporal_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/areacorporal_list.jsp';
<%
	}
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.hidePopWin(false);
<%
	}
} else throw new Exception(ACMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&caract=<%=caract%>&area=<%=codArea%>&caract_desc=<%=caractDesc%>&area_desc=<%=areaDesc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>