<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="iDiagLiq" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="vDiagLiq" scope="session" class="java.util.Vector"/>

<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
Admision adm = new Admision();
Admision resp = new Admision();
String key = "";
StringBuffer sbSql;
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String codigo = request.getParameter("codigo");
String id = request.getParameter("id");
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String fp = request.getParameter("fp");
if (fg == null) fg = "";
if (tab == null) tab = "1";
if(id==null) id="0";

boolean viewMode = false;
if (mode == null) mode = "add";
if (fp == null) fp = "adm";

CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoD = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
    StringBuffer sbFilter = new StringBuffer();
    
    if (change == null)
    {
        iDiagLiq.clear();
        vDiagLiq.clear();

        sbSql = new StringBuffer();
        sbSql.append("select a.id, a.codigo_reclamo, a.diagnostico, a.tipo, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.prioridad, (select coalesce(observacion,nombre) from tbl_cds_diagnostico where codigo=a.diagnostico) as diagnosticoDesc from tbl_pm_liquidacion_diag a where a.codigo_reclamo=");
        sbSql.append(codigo);
        
        al  = SQLMgr.getDataList(sbSql.toString());
        
        for (int i=1; i<=al.size(); i++)
        {
            cdoD = (CommonDataObject) al.get(i-1);

            if (i < 10) key = "00" + i;
            else if (i < 100) key = "0" + i;
            else key = "" + i;
            cdoD.setKey(key);
            cdoD.setAction("U");

            try
            {
                iDiagLiq.put(key, cdoD);
                vDiagLiq.addElement(cdoD.getColValue("diagnostico"));
            }
            catch(Exception e)
            {
                System.err.println(e.getMessage());
            }
        }
    }
    viewMode = mode.equals("view");
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Admisión - '+document.title;
function showDiagnosticoList(){
	abrir_ventana1('../common/check_diagnostico.jsp?fp=liq_recl&codigo=<%=codigo%>');
}


function doAction(){

<%
	if (request.getParameter("type") != null && request.getParameter("type").equals("1")){
%>
	showDiagnosticoList();
<%
	}
%>
}


function doSubmit(){
	document.form1.fechaNacimiento.value = parent.document.form0.fechaNacimiento.value;
	document.form1.codigoPaciente.value = parent.document.form0.codigoPaciente.value;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
	<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("tab","1")%>
	<%=fb.hidden("fg",fg)%>
	<%=fb.hidden("fp",fp)%>
	<%=fb.hidden("mode",mode)%>
	<%=fb.hidden("codigo",codigo)%>
	<%=fb.hidden("baction","")%>
	<%=fb.hidden("diagSize",""+iDiagLiq.size())%>
		<table width="100%" cellpadding="1" cellspacing="1">
			<tr class="TextHeader" align="center">
				<td width="15%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
				<td width="60%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
				<td width="10%"><cellbytelabel id="40">Prioridad</cellbytelabel></td>
				<td width="10%"><cellbytelabel id="16">Tipo</cellbytelabel></td>
				<td width="5%"><%=fb.submit("addDiagnostico","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnósticos")%></td>
			</tr>
		<%
		al = CmnMgr.reverseRecords(iDiagLiq);
		for (int i=1; i<=iDiagLiq.size(); i++)
		{
		key = al.get(i - 1).toString();
		cdoD = (CommonDataObject) iDiagLiq.get(key);
		%>
			<%=fb.hidden("key"+i,cdoD.getKey())%>
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("diagnostico"+i,cdoD.getColValue("diagnostico"))%>
			<%=fb.hidden("diagnosticoDesc"+i,cdoD.getColValue("diagnosticoDesc"))%>
			<%=fb.hidden("usuarioCreacion"+i,cdoD.getColValue("usuarioCreacion"))%>
			<%=fb.hidden("fechaCreacion"+i,cdoD.getColValue("fechaCreacion"))%>
			<%=fb.hidden("usuarioModifica"+i,cdoD.getColValue("usuarioModifica"))%>
			<%=fb.hidden("fechaModifica"+i,cdoD.getColValue("fechaModifica"))%>
			<%=fb.hidden("id"+i,cdoD.getColValue("id"))%>
            <%=fb.hidden("action"+i,cdoD.getAction())%>	
			<tr class="TextRow01">
				<td><%=cdoD.getColValue("diagnostico")%></td>
				<td><%=cdoD.getColValue("diagnosticoDesc")%></td>
				<td align="center"><%=fb.intBox("prioridad"+i,cdoD.getColValue("prioridad"),true,false,viewMode,2)%></td>
				<td align="center"><%=fb.select("tipo"+i,"I=INGRESO,S=SALIDA",cdoD.getColValue("tipo"),false,viewMode,0)%></td>
				<td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Diagnóstico")%></td>
			</tr>
		<%
		}
		%>
			</table>
		</td>
	</tr>

	<tr class="TextRow02">
		<td align="right">
			<cellbytelabel id="26">Opciones de Guardar</cellbytelabel>:
			<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
			<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="28">Mantener Abierto</cellbytelabel>
			<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="29">Cerrar</cellbytelabel>
			<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value);doSubmit();\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.window.close()\"")%>
		</td>
	</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";

		
    int size = 0;
    if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
    String itemRemoved = "";
    iDiagLiq.clear();
    vDiagLiq.clear();
    
    al.clear();
    
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdoD1 = new CommonDataObject();
            
            cdoD1.setTableName("tbl_pm_liquidacion_diag");
			cdoD1.addColValue("diagnostico",request.getParameter("diagnostico"+i));
			cdoD1.addColValue("diagnosticoDesc",request.getParameter("diagnosticoDesc"+i));
			cdoD1.addColValue("prioridad",request.getParameter("prioridad"+i));
			cdoD1.addColValue("tipo",request.getParameter("tipo"+i));
			cdoD1.addColValue("codigo_reclamo",codigo);
            
            System.out.println(":::::::::::::::::::::::::::::::: KEY = "+request.getParameter("key"+i));
            
            cdoD1.addColValue("key",request.getParameter("key"+i));
            cdoD1.setKey(request.getParameter("key"+i));
            cdoD1.setAction(request.getParameter("action"+i));
            
            if (request.getParameter("id"+i)==null || request.getParameter("id"+i).equals("0") || request.getParameter("id"+i).equals("") ) {
                cdoD1.setAutoIncCol("id");
            }else{
               cdoD1.addColValue("id",request.getParameter("id"+i));
               cdoD1.setWhereClause("id = "+request.getParameter("id"+i)+" and codigo_reclamo = "+codigo);
            } 
            
            if (mode.equals("add")){
              cdoD1.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			  cdoD1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			  cdoD1.addColValue("fecha_creacion",cDateTime);
			  cdoD1.addColValue("fecha_modificacion",cDateTime);
            }else {
              cdoD1.addColValue("fecha_modificacion",cDateTime);
               cdoD1.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
            }
            
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
				itemRemoved = cdoD1.getKey();
                if (cdoD1.getAction().equalsIgnoreCase("I")) cdoD1.setAction("X");
                else cdoD1.setAction("D");
			}
			
            if (!cdo.getAction().equalsIgnoreCase("X")){
				try{
					/*key = "";
					if (i < 10) key = "00"+i;
					else if (i < 100) key = "0"+i;
					else key = ""+i;
					cdoD1.setKey(key);*/
					iDiagLiq.put(cdoD1.getKey(),cdoD1);
                    vDiagLiq.add(cdoD1.getColValue("diagnostico"));
                    al.add(cdoD1);
					System.out.println("key..."+cdoD1.getKey());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
		   }
       } // for
       
		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&codigo="+codigo);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=1&mode="+mode+"&codigo="+codigo);
			return;
		}
        
        System.out.println("::::::::::::::::::::::::::::::::::::: AL.SIZE() = "+al.size());
        
        if(baction != null && baction.equals("Guardar")){
            if (al.size() == 0){
                cdo = new CommonDataObject();
                cdo.setTableName("tbl_pm_liquidacion_diag");
                cdo.setAction("I");
                al.add(cdo);
                System.out.println("?????::::::::::::::::::::::::::::::::::::: AL.SIZE() = "+al.size());
            }
            
            System.out.println("-----::::::::::::::::::::::::::::::::::::: AL.SIZE() = "+al.size());
            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
            SQLMgr.saveList(al,true);
            ConMgr.clearAppCtx(null);
            
            errCode = SQLMgr.getErrCode();
            errMsg = SQLMgr.getErrMsg();
        }
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
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
	if (parent.window) parent.window.close();
	else window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&codigo=<%=codigo%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&fp=<%=fp%>&mode=edit&tab=<%=tab%>&codigo=<%=codigo%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>