<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="java.util.Hashtable"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iAseg" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vDoc" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String docId = "";
String fp = request.getParameter("fp");
String change = request.getParameter("change");
int docLastLineNo = 0;

String key = "";

if (mode == null) mode = "add";
if (request.getParameter("docLastLineNo") != null) docLastLineNo = Integer.parseInt(request.getParameter("docLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
if (change == null)
{ 
 System.out.println("pacId = ====  "+pacId);
vDoc.clear();
iDoc.clear();
}
 if (pacId != null && !pacId.trim().equals("") && change == null)
 {
 vDoc.clear();
 iDoc.clear();
 sql="select a.documento, a.revisado_admision,a.revisado_sala,a.revisado_fac,a.revisado_cob, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_creacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fecha_modificacion, a.usuario_creacion , a.usuario_modificacion, b.nombre as documentoDesc,a.observacion,a.estatus ,to_char(a.fecha_recibe,'dd/mm/yyyy')fecha_recibe,to_char(a.fecha_entrega,'dd/mm/yyyy')fecha_entrega ,a.user_recibe,a.user_entrega,a.area_recibe,a.area_entrega, a.pase,a.pase_k from tbl_adm_documentos_admision a, tbl_adm_documento b where a.documento=b.codigo and a.admision= "+noAdmision+" and a.pac_id="+pacId+" order by a.documento";

      al  = SQLMgr.getDataList(sql);

      docLastLineNo = al.size();
      for (int i=1; i<=al.size(); i++)
      {
         cdo = (CommonDataObject) al.get(i-1);

        if (i < 10) key = "00" + i;
        else if (i < 100) key = "0" + i;
        else key = "" + i;
        cdo.addColValue("key",key);

        try
        {
          iDoc.put(key, cdo);
          vDoc.addElement(cdo.getColValue("documento"));
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }
}

System.out.println("change = "+change+"     docLastLineNo  ==  "+docLastLineNo);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title="Facturacion - Corte Cuenta - "+document.title;


function doAction()
{
  //setHeight('secciones',document.body.scrollHeight);
	<%
    if (request.getParameter("type") != null && request.getParameter("type").trim().equals("1"))
    {
%>
  showDocumentoList();
<%
    }
%>

}
function showDocumentoList()
{
  abrir_ventana1('../common/check_documento.jsp?fp=revision&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&docLastLineNo=<%=docLastLineNo%>');
}
function doSobmit(formName,value)
{

	setBAction(formName,value);
	//document.form0.baction.value = 'Guardar';
	//document.form0.saveOption.value = parent.document.form0.saveOption.value;
	document.form0.dob.value = document.paciente.fechaNacimiento.value;
	document.form0.codPac.value = document.paciente.codigoPaciente.value;
	document.form0.pacId.value = document.paciente.pacienteId.value;
	document.form0.noAdmision.value = document.paciente.admSecuencia.value;
	
	if (document.form0.baction.value == 'Guardar' && !form0Validation())
	{
		form0BlockButtons(false);
		return false;
	}
	document.form0.submit();
	
}
function selCds(k)
{
abrir_ventana1('../common/sel_centro_servicio.jsp?fg=rev_docCds');
}
function selCds1(k)
{
abrir_ventana1('../common/sel_centro_servicio.jsp?fg=rev_docCds1');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="FACTURACION"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
  <td class="TableBorder">
    <table align="center"  width="100%" cellpadding="5" cellspacing="0">
    <tr>
      <td class="TableBorder">
        <table width="100%" cellpadding="1" cellspacing="0">
        <tr class="TextRow02">
          <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
          <td width="100%">
<jsp:include page="../common/paciente.jsp" flush="true">
  <jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
  <jsp:param name="fp" value="revision_doc"></jsp:param>
  <jsp:param name="mode" value="<%=mode%>"></jsp:param>
  <jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
</jsp:include>
          </td>
        </tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("change",change)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("docSize",""+iDoc.size())%>

<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>


        <tr class="TextRow01">
          <td width="29%" class="TableBorder TextRow01" valign="top" colspan="2">
            <table width="100%" cellpadding="1" cellspacing="1" align="center">
						<tr class="TextRow01" align="center">
							<td colspan="3">&nbsp;</td>
						</tr>  
						
						<tr class="TextHeader" align="center">
              <td width="05%">C&oacute;digo</td>
              <td width="35%">Nombre</td>
							<td width="35%">Verificado</td>
							<td width="20%">Observación</td>
						  <td width="5%"><%=fb.submit("addDocumento","+",false,false,null,null,"onClick=\"javascript:doSobmit('"+fb.getFormName()+"',this.value)\"","Agregar Documentos")%></td>
            </tr>
						<tr>
							<td  colspan="5" style="text-decoration:none;">
							<div id="listado" width="100%" style="overflow:scroll;position:relative;height:500">
							<div id="detListado" width="100%" style="overflow;position:absolute">
								<table width="100%" cellpadding="1" cellspacing="0">
								<tr class="TextRow01">
						          
						
            <%
						al = CmnMgr.reverseRecords(iDoc);
									System.out.println("===================== iDoc   SIZE  =="+iDoc.size());
	
for (int i=1; i<=iDoc.size(); i++)
{
	System.out.println("===================== DOCUMENTOS  I  =="+i);
	key = al.get(i-1).toString();		
	cdo = (CommonDataObject) iDoc.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
	
%>
			 			<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
            <%=fb.hidden("remove"+i,"")%>
            <%=fb.hidden("documento"+i,cdo.getColValue("documento"))%>
            <%=fb.hidden("documentoDesc"+i,cdo.getColValue("documentoDesc"))%>
            <%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
            <%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
            <%=fb.hidden("usuario_modificacion"+i,cdo.getColValue("usuario_modificacion"))%>
            <%=fb.hidden("fecha_modificacion"+i,cdo.getColValue("fecha_modificacion"))%>
						<%=fb.hidden("revisado_admision"+i,cdo.getColValue("revisado_admision"))%>
						
						<%=fb.hidden("revisado_sala"+i,cdo.getColValue("revisado_sala"))%>
						<%=fb.hidden("revisado_fac"+i,cdo.getColValue("revisado_fac"))%>
						<%=fb.hidden("revisado_cob"+i,cdo.getColValue("revisado_cob"))%>
						<%=fb.hidden("pase"+i,cdo.getColValue("pase"))%>
						<%=fb.hidden("pase_k"+i,cdo.getColValue("pase_k"))%>
									
            <tr class="<%=color%>">
              <td rowspan="2" width="05%"><%=cdo.getColValue("documento")%></td>
              <td width="35%"><%=cdo.getColValue("documentoDesc")%></td>
              <td align="center" width="35%"><%=fb.select("estatus"+i,"VE=VERIFICADO,NV=NO VERIFICADDO,NR=NO RECIBIDO",cdo.getColValue("estatus"),false,false,0,"S")%></td>
							<td rowspan="2" width="20%"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,false,30,2,2000,null,"","")%></td>
							
						
              <td rowspan="2" width="05%" align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Documento")%></td>
            </tr>
						





					<tr class="<%=color%>">
						<td>Fecha Rec.
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="format" value="dd/mm/yyyy"/>
							<jsp:param name="nameOfTBox1" value="<%="fecha_recibe"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_recibe")%>" />
							</jsp:include>
							Por:
							<%=fb.textBox("user_recibe"+i,cdo.getColValue("user_recibe"),false,false,false,20,30)%><br>
							
				Area Recibe: <%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo, codigo from tbl_cds_centro_servicio where recibe_documentos ='S' ","area_recibe"+i,cdo.getColValue("area_recibe"),false,false,0,"Text10",null,null,"","S")%></td>
							
							<td> Fecha Entr.
							<jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1"/>
							<jsp:param name="format" value="dd/mm/yyyy"/>
							<jsp:param name="nameOfTBox1" value="<%="fecha_entrega"+i%>" />
							<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_entrega")%>" />
							</jsp:include>
							Por:<%=fb.textBox("user_entrega"+i,cdo.getColValue("user_entrega"),false,false,false,20,30)%>
							<br>
				Area Entrega:
				<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion||' - '||codigo, codigo from tbl_cds_centro_servicio where entrega_documentos ='S' ","area_entrega"+i,cdo.getColValue("area_entrega"),false,false,0,"Text10",null,null,"","S")%>
				     </td>
						
						
          </tr>  
						
  <%}%>         
           </table>
						</div>
						</div>
					</td>
				</tr>
					 
					  </table>
           
          </td>
         
        </tr>
				<tr class="TextRow02" align="right">
					<td colspan="5">
					Opciones de Guardar:
					<!--<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro-->
					<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto
					<%=fb.radio("saveOption","C",false,false,false)%>Cerrar
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:doSobmit('"+fb.getFormName()+"',this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
        
<%=fb.formEnd(true)%>

        </table>
      </td>
    </tr>
    </table>
  </td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else {

 //DOCUMENTOS
		String baction = request.getParameter("baction");
		String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
    int size = 0;
    if (request.getParameter("docSize") != null) size = Integer.parseInt(request.getParameter("docSize"));
    String itemRemoved = "";
		pacId = request.getParameter("pacId");
		noAdmision = request.getParameter("noAdmision");
		
    for (int i=1; i<=size; i++)
    {
      CommonDataObject obj = new CommonDataObject();
			
			
			obj.setTableName("tbl_adm_documentos_admision");
			obj.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision")+" ");
						
			obj.addColValue("pac_id",request.getParameter("pacId"));
			obj.addColValue("admision",request.getParameter("noAdmision"));
			obj.addColValue("fecha_nacimiento",request.getParameter("dob"));
			obj.addColValue("paciente",request.getParameter("codPac"));
			
     	 	obj.addColValue("documento",request.getParameter("documento"+i));
      		obj.addColValue("documentoDesc",request.getParameter("documentoDesc"+i));
   
			obj.addColValue("area_entrega",request.getParameter("area_entrega"+i));
			obj.addColValue("area_recibe",request.getParameter("area_recibe"+i));

			obj.addColValue("user_recibe",request.getParameter("user_recibe"+i));
			obj.addColValue("user_entrega",request.getParameter("user_entrega"+i));
			obj.addColValue("fecha_recibe",request.getParameter("fecha_recibe"+i));
			obj.addColValue("fecha_entrega",request.getParameter("fecha_entrega"+i));
			obj.addColValue("observacion",request.getParameter("observacion"+i));
			obj.addColValue("estatus",request.getParameter("estatus"+i));
			obj.addColValue("revisado_admision",request.getParameter("revisado_admision"+i));
		    obj.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
		    obj.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
		    obj.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		    obj.addColValue("key",request.getParameter("key"+i));
 			
			obj.addColValue("revisado_sala",request.getParameter("revisado_sala"+i));
			obj.addColValue("revisado_fac",request.getParameter("revisado_fac"+i));
			obj.addColValue("revisado_cob",request.getParameter("revisado_cob"+i));
			obj.addColValue("pase",request.getParameter("pase"+i));
			obj.addColValue("pase_k",request.getParameter("pase_k"+i));


      if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
        itemRemoved = obj.getColValue("Key");
      else
      {
        try
        {
          iDoc.put(obj.getColValue("key"),obj);
          al.add(obj);
        }
        catch(Exception e)
        {
          System.err.println(e.getMessage());
        }
      }
    }

    if (!itemRemoved.equals(""))
    {
		  CommonDataObject obj = (CommonDataObject) iDoc.get(itemRemoved);
      vDoc.remove(obj.getColValue("documento"));
      iDoc.remove(itemRemoved);

      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&docLastLineNo="+docLastLineNo);
      return;
    }

    if (baction != null && baction.equals("+"))
    {
      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&docLastLineNo="+docLastLineNo);
      return;
    }

    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    SQLMgr.insertList(al);
    ConMgr.clearAppCtx(null);
   //errCode = AdmMgr.getErrCode();
    //errMsg = AdmMgr.getErrMsg();

%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/admision_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/admision/admision_list.jsp';
<%
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
	parent.doRedirect(0);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>




