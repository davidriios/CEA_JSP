<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.expediente.Factores"%>
<%@ page import="issi.expediente.DetalleFactor"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
FG 				TIPOS DE ESCALA
NO 				NORTON
CR				CRIES
NI				NIPS
WB				WONG BAKER
AN				ANALOGA
SG              SUSAN GIVENS
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

Factores fa = new Factores();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fg = request.getParameter("fg");

int lastLineNo = 0;

if (mode == null) mode = "add";
if (fg == null) fg = "NO";

if (request.getParameter("lastLineNo") != null) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
	    HashDet.clear();
		id = "0";
	}
	else
	{
		if (id == null) throw new Exception("El Factor de la Escala Norton no es válido. Por favor intente nuevamente!");

		sql = "SELECT codigo, descripcion,estado,tipo, presentar_check presentarCheck, orden, habilitar_intervencion habilitarInterv FROM tbl_sal_concepto_norton WHERE codigo="+id+" and tipo = '"+fg+"'";
		fa = (Factores) sbb.getSingleRowBean(ConMgr.getConnection(),sql, Factores.class);		
		//System.out.println("sql =="+sql);
		if (change == null)
		{
			sql = "SELECT codigo, secuencia, descripcion, valor,estado, 'A' status, orden FROM tbl_sal_det_concepto_norton WHERE codigo="+id+" and tipo = '"+fg+"' ORDER BY orden";
            al = sbb.getBeanList(ConMgr.getConnection(), sql, DetalleFactor.class);
			//System.out.println("sql Det =="+sql);
            HashDet.clear(); 
			lastLineNo = al.size();
			for (int i = 1; i <= al.size(); i++)
			{
			  if (i < 10) key = "00" + i;
			  else if (i < 100) key = "0" + i;
			  else key = "" + i;

			  HashDet.put(key, al.get(i-1));
		    }  	 			
		}
	}
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Factores de la Escala de Norton - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Factores de la Escala de Norton - Edición - "+document.title;
<%}%>
function saveMethod()
{
  if (form0Validation())
  {  
     window.frames['itemFrame'].formFactor.baction.value = "Guardar";
     window.frames['itemFrame'].doSubmit();
  }  
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%//=fb.hidden("fg",""+fg)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Generales</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="4%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							    <td width="7%"><%=fb.intBox("codigo",fa.getCodigo(),false,false,true,5,3)%></td>														
								<td width="40%">
                                <cellbytelabel id="3">Descripci&oacute;n</cellbytelabel>
								<%=fb.textBox("descripcion",fa.getDescripcion(),true,false,false,50,2000)%></td>
								<td width="20%"><cellbytelabel id="4">Tipo</cellbytelabel><%=fb.select("fg","NO=ESCALA DE NORTON,NI=NIPS,WB=WONG BAKER,CR=CRIES,AN=ANALOGA,MO=MORSE,BR=BRADEN,SG=SUSAN GIVENS,DO=ESCALA DOWNTON,CA=CAMPBELL,MAC=MACDEMS,MM5=MENORES DE 5 AÑOS,DF=DISCAPACIDAD FISICA,FOUR=ESCALA DE FOUR,TVP=ESACALA TPV - TEV,RAM=RAMSEY,OT=OTRAS",fg,false,false,0,"")%></td>	
								<td width="10%"><%=fb.select("estado","A= ACTIVO,I=INACTIVO",fa.getEstado(),false,false,0,"",null,"")%></td>				
								<td width="20%">
                                <%if(fg.trim().equalsIgnoreCase("DO")){%>
                                    <label class="pointer">
                                        Checkbox? <%=fb.checkbox("presentar_check","Y",fa.getPresentarCheck()!=null&&fa.getPresentarCheck().equalsIgnoreCase("Y"),false,null,null,"","")%>
                                    </label>
                                <%}%>
                                Orden:
                                <%=fb.intBox("orden",fa.getOrden(),false,false,false,5,2)%>
								
								<label class="pointer">
									<%if(fa.getHabilitarInterv()!=null&&fa.getHabilitarInterv().equalsIgnoreCase("Y")){%>
										<%=fb.checkbox("habilitar_intervencion_dummy","Y",true,true,null,null,"","")%>
										<b>Intervenci&oacute;n</b>
										<%=fb.hidden("habilitar_intervencion","Y")%>
									<%} else {%>
									<%=fb.checkbox("habilitar_intervencion","Y",fa.getHabilitarInterv()!=null&&fa.getHabilitarInterv().equalsIgnoreCase("Y"),false,null,null,"","")%>
									<b>Intervenci&oacute;n?</b>
									<%}%>
                                </label>
                                </td>    
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;<cellbytelabel id="5">Detalles</cellbytelabel></td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="50" scrolling="no" src="../expediente/detallefactor_config.jsp?mode=<%=mode%>&lastLineNo=<%=lastLineNo%>&fg=<%=fg%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="6">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="7">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="8">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="9">Cerrar</cellbytelabel> 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod()\"")%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
else
{
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
  String errCode = request.getParameter("errCode");
  String errMsg = request.getParameter("errMsg");
  fg = request.getParameter("fg");
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/factoresnorton_list.jsp?fg="+fg))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/factoresnorton_list.jsp?fg="+fg)%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/expediente/factoresnorton_list.jsp?fg=<%=fg%>';
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
	window.close();
<%
	}
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>