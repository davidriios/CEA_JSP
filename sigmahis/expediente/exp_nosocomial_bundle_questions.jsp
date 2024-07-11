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
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iQuestions" scope="session" class="java.util.Hashtable" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String tab = request.getParameter("tab");
String codigoBundle = request.getParameter("codigo_bundle");
String tubo = request.getParameter("tubo");
String tuboDesc = request.getParameter("tubo_desc");
String medida = request.getParameter("medida");
String medidaDesc = request.getParameter("medida_desc");
String change = request.getParameter("change");
String codigo = request.getParameter("codigo");
int detLastLineNo = 0;

if (mode == null) mode = "add";
if (codigo == null) codigo = "0";
if (tab == null) tab = "0";
if (request.getParameter("detLastLineNo") != null) detLastLineNo = Integer.parseInt(request.getParameter("detLastLineNo"));

if (tubo == null) tubo = "0";
if (tuboDesc == null) tuboDesc = "";
if (medida == null) medida = "0";
if (medidaDesc == null) medidaDesc = "";

if (request.getMethod().equalsIgnoreCase("GET")){

    if (codigoBundle == null) throw new Exception("El Código del Bundle no es válido. Por favor intente nuevamente!");
    
    sql = "select count(*) from tbl_sal_tubo_medida_preguntas where codigo_tub_med = "+codigoBundle;
    int totQuestions = CmnMgr.getCount(sql);

    System.out.println(sql);

    if (totQuestions > 0) mode = "edit";
    
	if (mode.equalsIgnoreCase("add")){
		codigo = "0";
        if (change == null) {
            iQuestions.clear();
            al.clear();
        }
	}
	else{
	
		if (change == null){
			iQuestions.clear();
            al.clear();
            
			sql = "select codigo, codigo_tub_med, pregunta, orden, estado, activar_obs, totalizador, supervisor from tbl_sal_tubo_medida_preguntas where codigo_tub_med = "+codigoBundle+" order by orden";

            al = SQLMgr.getDataList(sql);

			detLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++){
				CommonDataObject det = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				det.setKey(key);

				iQuestions.put(key,det);
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
function abbleToSubmit() {
    var proceed = true;
    if ($("input[name*='totalizado']:checked").length > 1) {
        alert("No puedes seleccionar a mas de un totalizador!");
        proceed = false;
    }
    return proceed;
}
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
        <%=fb.hidden("codigo_bundle",codigoBundle)%>
        <%=fb.hidden("tubo",tubo)%>
        <%=fb.hidden("tubo_desc",tuboDesc)%>
        <%=fb.hidden("medida",medida)%>
        <%=fb.hidden("medida_desc",medidaDesc)%>
        <%=fb.hidden("codigo",codigo)%>
        <%=fb.hidden("detLastLineNo",""+detLastLineNo)%>
        <%=fb.hidden("size",""+iQuestions.size())%>
        <%fb.appendJsValidation("if(!abbleToSubmit())error++;");%>

		<tr class="TextRow02">
			<td colspan="7">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Tubo</cellbytelabel></td>
			<td colspan="7">[<%=tubo%>] <%=tuboDesc%></td>
		</tr>
        <tr class="TextRow01">
			<td><cellbytelabel>Medida</cellbytelabel></td>
			<td colspan="7">[<%=medida%>] <%=medidaDesc%></td>
		</tr>
		<tr class="TextHeader" align="center">
			<td width="7%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
			<td width="40%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Orden</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Totalizador</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Activar obs.</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Supervisor</cellbytelabel></td>
			<td width="10%"><cellbytelabel>Estado</cellbytelabel></td>
			<td width="3%">
                <%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%>
			</td>
		</tr>
<%
al = CmnMgr.reverseRecords(iQuestions);
for (int i = 1; i <= iQuestions.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject det = (CommonDataObject) iQuestions.get(key);
	String displayDetalle = "";
	if (det.getColValue("action") != null && det.getColValue("action").equalsIgnoreCase("D")) displayDetalle = " style=\"display:none\"";
%>
		<%=fb.hidden("key"+i,det.getKey())%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("action"+i,det.getAction())%>
		<tr class="TextRow01" align="center"<%=displayDetalle%>>
			<td><%=fb.intBox("codigo"+i,det.getColValue("codigo"),false,false,true,5)%></td>
			<td><%=fb.textBox("pregunta"+i,det.getColValue("pregunta"),true,false,false,85)%></td>
            <td>
              <%=fb.intBox("orden"+i, det.getColValue("orden"),false,false,false,5)%>
            </td>
            <td align="center">
                <%=fb.checkbox("totalizador"+i,"S",(det.getColValue("totalizador")!=null && det.getColValue("totalizador").equalsIgnoreCase("S")),false)%>
            </td>
            <td align="center">
                <%=fb.checkbox("activar_obs"+i,"S",(det.getColValue("activar_obs")!=null && det.getColValue("activar_obs").equalsIgnoreCase("S")),false)%>
            </td>
            <td align="center">
                <%=fb.checkbox("supervisor"+i,"S",(det.getColValue("supervisor")!=null && det.getColValue("supervisor").equalsIgnoreCase("S")),false)%>
            </td>
            <td align="center">
                <%=fb.select("estado"+i,"A=Activo,I=Inactivo",det.getColValue("estado"),"")%>
            </td>
			<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeDetail("+i+")\"")%></td>
		</tr>
<%
}
%>
		<tr class="TextRow02">
			<td align="right" colspan="7">
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
    
    al.clear();
    iQuestions.clear();
    
    for (int i=1; i<=size; i++) {
        CommonDataObject det = new CommonDataObject();
        
        det.setTableName("tbl_sal_tubo_medida_preguntas");
        
        det.addColValue("pregunta", request.getParameter("pregunta"+i));
        det.addColValue("orden", request.getParameter("orden"+i));
        det.addColValue("codigo_tub_med", codigoBundle);
        det.addColValue("estado", request.getParameter("estado"+i));
        det.addColValue("codigo", request.getParameter("codigo"+i));
        
        if (request.getParameter("activar_obs"+i)!=null) det.addColValue("activar_obs","S");
        else det.addColValue("activar_obs","N");
        
        if (request.getParameter("supervisor"+i)!=null) det.addColValue("supervisor","S");
        else det.addColValue("supervisor","N");
        
        if (request.getParameter("totalizador"+i)!=null) det.addColValue("totalizador","S");
        else det.addColValue("totalizador","N");
        
        if (request.getParameter("codigo"+i) != null &&request.getParameter("codigo"+i).equals("0")) {
            det.setAutoIncCol("codigo");
            det.setAction("I");
            det.addColValue("codigo", "0");
        } else {
            det.setAction("U");
            det.setWhereClause("codigo = "+request.getParameter("codigo"+i)+" and codigo_tub_med = "+codigoBundle);
        }

        det.setKey(request.getParameter("key"+i));

        if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
            itemRemoved = det.getKey();
            det.setAction("D");
        }
        try{
            iQuestions.put(det.getKey(),det);
            al.add(det);
        }
        catch(Exception e) {
            System.err.println(e.getMessage());
        }
	}

    if (!itemRemoved.equals("")) {
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&codigo="+codigo+"&detLastLineNo="+detLastLineNo+"&tubo="+tubo+"&medida="+medida+"&tubo_desc="+tuboDesc+"&medida_desc="+medidaDesc+"&codigo_bundle="+codigoBundle);
        return;
    }

    if (baction != null && baction.equals("+")) {
        CommonDataObject det = new CommonDataObject();

        detLastLineNo++;
        if (detLastLineNo < 10) key = "00" + detLastLineNo;
        else if (detLastLineNo < 100) key = "0" + detLastLineNo;
        else key = "" + detLastLineNo;
        det.addColValue("codigo","0");
        det.addColValue("codigo_tub_med", codigoBundle);
        det.addColValue("codigo_bundle", codigoBundle);
        det.setKey(key);
        det.setAction("I");

        try{
            iQuestions.put(det.getKey(),det);
            al.add(det);
        }
        catch(Exception e)
        {
            System.err.println(e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&codigo="+codigo+"&detLastLineNo="+detLastLineNo+"&tubo="+tubo+"&medida="+medida+"&tubo_desc="+tuboDesc+"&medida_desc="+medidaDesc+"&codigo_bundle="+codigoBundle);
        return;
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    SQLMgr.saveList(al,true,true);
    ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&codigo=<%=codigo%>&codigo_bundle=<%=codigoBundle%>&tubo=<%=tubo%>&medida=<%=medida%>&tubo_desc=<%=tuboDesc%>&medida_desc=<%=medidaDesc%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>