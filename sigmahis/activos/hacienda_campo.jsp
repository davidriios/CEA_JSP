<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.ClasificacionActivos"%>
<%@ page import="issi.contabilidad.DetalleClasificacion"%>
<%@ page import="issi.contabilidad.ClasificacionActivosMgr"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<jsp:useBean id="ITEMS" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="ITEMS_KEY" scope="session" class="java.util.Vector" />

<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="clasif" scope="page" class="issi.contabilidad.ClasificacionActivos" />
<jsp:useBean id="CAMgr" scope="page" class="issi.contabilidad.ClasificacionActivosMgr" />


<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CAMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

int lastLineNo = 0;
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
ArrayList al = new ArrayList();
String key = "";
String change =  request.getParameter("change");

if (request.getMethod().equalsIgnoreCase("GET")){
if(request.getParameter("lastLineNo")!=null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo")); 
sql = "SELECT cod_clasif id, descripcion,estado  FROM tbl_con_clasif_hacienda WHERE cod_clasif="+id;
 clasif = (ClasificacionActivos) sbb.getSingleRowBean(ConMgr.getConnection(),sql,ClasificacionActivos.class);
 if(clasif== null)
 {
 	clasif = new ClasificacionActivos();
	clasif.setId("0");
	id="0";
 }
//-------------------------------------------------- CARGA HASHTABLE --------------------------------------------------
if (change == null) {
ITEMS.clear();
ITEMS_KEY.clear();
sql = " SELECT a.chacienda AS chacienda, a.cod_campos AS id, b.descripcion AS descripcion, a.estado,'U' status FROM tbl_con_campos_por_clasif a, tbl_con_lista_campos b WHERE a.chacienda="+id+" AND b.secuencia_campos=cod_campos ";
//al  = SQLMgr.getDataList(sql); 
al  = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleClasificacion.class);
lastLineNo = al.size();
for (int i = 1; i <= al.size(); i++){
    
	 DetalleClasificacion dc = (DetalleClasificacion) al.get(i-1);
	if (i < 10) key = "00" + i;
    else if (i < 100) key = "0" + i;
    else key = "" + i;
    ITEMS.put(key, dc);
	ITEMS_KEY.addElement(dc.getId());
    }  	
}
//---------------------------------------------------------------------------------------------------------------------

%>

<HTML>
<HEAD>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Hacienda - '+document.title;
function addCampo()
{
  abrir_ventana1('../activos/hacienda_campo_popup.jsp?id=<%=id%>&lastLineNo=<%=lastLineNo%>');
}

function removeItem(fName,k)
{
	 var code =  parent.document.form1.id.value;
	 var subCode = eval('document.form1.cod_campos'+k).value;
	 var existe = 0;
	 
	  existe = getDBData('<%=request.getContextPath()%>',' count(*) existe','tbl_con_resp_por_campos','cod_clasif= '+code+' and sec_campos = '+subCode+' ','');
		//existe += getDBData('<%=request.getContextPath()%>',' count(*) existe','tbl_sal_detalle_esc',' cod_escala = '+code+' and detalle = '+subCode+' ','');

		if(existe >0)
		{
			alert('No se puede eliminar el registro.');
			return;
		}
		else
		{
			eval('document.form1.status'+k).value='D';
			var rem = eval('document.'+fName+'.rem'+k).value;
			eval('document.'+fName+'.remove'+k).value = rem;
			setBAction(fName,rem);
			document.form1.submit(); 
		}
	
}
</script>
</HEAD>
<BODY topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="CONTABILIDAD - ACTIVO FIJO - MANTENIMIENTO"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
<td class="TableBorder">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<% fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST); %>
<%=fb.formStart(true)%>		
<%=fb.hidden("lastLineNo",""+lastLineNo)%>
<%=fb.hidden("mode", mode)%>
<%=fb.hidden("keySize",""+ITEMS.size())%>
<%=fb.hidden("id",id)%>		
<%=fb.hidden("baction","")%>		
<tr>
<td colspan="2">&nbsp;</td>
</tr>
<tr class="TextRow02">
<td colspan="2">&nbsp;</td>
</tr>			
<tr class="TextRow01">
  <td>C&oacute;digo:</td>
  <td>&nbsp;<%=clasif.getId()%></td>
</tr>
<tr class="TextRow01">
<td width="15%">Hacienda:</td>
<td width="85%">&nbsp;<%=fb.textBox("descripcion",clasif.getDescripcion(),false,false,true,50)%></td>				
</tr>


<tr class="TextRow01"><td height="5"></td><td></td></tr>
<tr class="TextRow01">
<td colspan="2">

</td>
</tr>					
<tr class="TextRow02">
<td colspan="2" align="right">

<table width="100%" border="1">
<tr class="TextRow01" align="center">
  <td colspan="3" ></td>
  </tr>
<tr class="TextHeader"  align="center">
<td width="10%">Código</td>
<td width="65%">Campo</td>
<td width="15%">Estado</td>
<td width="10%" align="center"><%=fb.button("btncampo","Agregar",true,false,null,null,"onClick=\"javascript:addCampo()\"")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(ITEMS);				
for (int i = 1; i <= ITEMS.size(); i++) {
  key = al.get(i - 1).toString();									  
  //CommonDataObject cdo1 = (CommonDataObject) ITEMS.get(key);
  DetalleClasificacion dc = (DetalleClasificacion) ITEMS.get(key);
  
  String displayDet="";
  if (dc.getStatus() != null && dc.getStatus().equalsIgnoreCase("D")) displayDet = " style=\"display:none\"";
%>
<%=fb.hidden("remove"+i,"")%>	
<%=fb.hidden("status"+i,dc.getStatus())%>
<%=fb.hidden("key"+i,key)%>
<% fb.appendJsValidation("if (document."+fb.getFormName()+".baction.value=='X' && document."+fb.getFormName()+".cod_campos"+i+".value=='') { return true; }"); %>
<tr align="center" class="TextRow01" <%=displayDet%>>
	<td><%=fb.textBox("cod_campos"+i, dc.getId(),(!dc.getStatus().trim().equals("D"))?true:false,false,true,20)%></td>
	<td><%=fb.textBox("descripcion"+i,dc.getDescripcion(),(!dc.getStatus().trim().equals("D"))?true:false,false,true,50)%></td>
	<td><%=fb.select("estado"+i,"A= ACTIVO,I=INACTIVO",dc.getEstado(),false,false,0,"",null,"","","")%></td>
	<td><%=fb.button("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
<% } %>
</table>




</td>
</tr>	

<tr class="TextRow02">
<td colspan="3" align="right"> 
<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:document."+fb.getFormName()+".baction.value=this.value\"")%>
<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
</td>
</tr>	
<% fb.appendJsValidation("if (document."+fb.getFormName()+".baction.value=='Guardar' && "+ITEMS.size()+"<=0) { alert(\"Agregue por lo menos un campo antes de guardar!\"); error++; }"); %>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</table>		
</td>
</tr>
</table>
</BODY>
</HTML>

<% } /*GET*/ else 
{

 String ItemRemoved = "";
 String baction = request.getParameter("baction");
 ArrayList list = new ArrayList();
 lastLineNo  = Integer.parseInt(request.getParameter("lastLineNo"));
 int keySize = Integer.parseInt(request.getParameter("keySize"));
 mode = request.getParameter("mode");
 id = request.getParameter("id");
	clasif.setId(id);
	clasif.getDetalle().clear();
	for (int i=1; i<=keySize; i++)
	{
	key = request.getParameter("key"+i);

		DetalleClasificacion det = new DetalleClasificacion(); 
		
		
		det.setId(request.getParameter("cod_campos"+i));
		det.setDescripcion(request.getParameter("descripcion"+i));
		det.setEstado(request.getParameter("estado"+i));//
		
	if (request.getParameter("remove"+i)!= null && !request.getParameter("remove"+i).equals("")) 
	{ 
		ItemRemoved = key;  
		det.setStatus("D");
	} 
	
	try 
	{
		det.setStatus(request.getParameter("status"+i));//add,update, delete
		list.add(det); 
		ITEMS.put(key, det); 
		clasif.getDetalle().add(det);
	
	}	
	catch(Exception e)
	{
		System.err.println(e.getMessage());
	}

	} //End For

		if (!ItemRemoved.equals(""))
		{
		ITEMS_KEY.remove(((DetalleClasificacion)ITEMS.get(ItemRemoved)).getId()); 	
    	//ITEMS.remove(ItemRemoved);  
		 response.sendRedirect("../activos/hacienda_campo.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&id="+id+"&change=1");
    	return;
		}
if (baction.equalsIgnoreCase("Guardar"))
{		
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	CAMgr.addDetalle(clasif);
	ConMgr.clearAppCtx(null);
}
%>

<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (CAMgr.getErrCode().equals("1"))
{
%>
	alert('<%=CAMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"activos/hacienda_campo.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"activos/hacienda_campo.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/activos/clasificacion_activo.jsp';
<%
	}
%>
	window.close();
<%
} else throw new Exception(CAMgr.getErrMsg());
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