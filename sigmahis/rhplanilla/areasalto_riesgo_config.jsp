<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="hastarea" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="hastusua" scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="AEmpMgr" scope="page" class="issi.rhplanilla.AsistenciaEmpMgr" />
<jsp:useBean id="IXml" scope="page" class="issi.admin.XMLCreator" />
<jsp:useBean id="vUser" scope="session" class="java.util.Vector"/>
<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
AEmpMgr.setConnection(ConMgr); 
IXml.setConnection(ConMgr); 
CommonDataObject grp= new CommonDataObject();
ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String code=request.getParameter("code");
String tab = request.getParameter("tab");
String key="";
String change = request.getParameter("change");
int lastLineArea = 0;
int lastLineUsuario = 0;

if(tab == null)  tab = "0";
if(mode == null) mode ="add";

if(request.getParameter("lastLineArea") != null)
lastLineArea = Integer.parseInt(request.getParameter("lastLineArea"));

if(request.getParameter("lastLineUsuario") !=null)
lastLineUsuario = Integer.parseInt(request.getParameter("lastLineUsuario"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";	
		code="0";
		grp.addColValue("codigo","0");
		hastarea.clear();
		hastusua.clear();
		
	}
	else
	{
		if (id == null) throw new Exception("El Grupo no es válido. Por favor intente nuevamente!");

		sql = "select codigo, compania, descripcion, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion from tbl_pla_ct_grupo WHERE compania="+(String) session.getAttribute("_companyId")+" and codigo="+id;
		grp = SQLMgr.getData(sql);
	
	if(change== null)
	{
	sql="select codigo, grupo, compania, nombre, usuario_creacion, fecha_creacion, usuario_modificacion, fecha_modificacion, estado, area_alto_riesgo, valor_alto_riesgo_quinc, valor_alto_riesgo_turno, abreviatura, nombre_corto from tbl_pla_ct_area_x_grupo where compania="+(String) session.getAttribute("_companyId")+" and grupo="+id;
	al = SQLMgr.getDataList(sql);
		hastarea.clear();
		hastusua.clear();
	lastLineArea = al.size();		
	for(int i=0; i<al.size();i++)
	{
	lastLineArea++;
	if(lastLineArea<10)
	key ="00" + lastLineArea;
	else if (lastLineArea <100)
	key = "0" + lastLineArea;
	else key= "" + lastLineArea;
	
	hastarea.put(key,al.get(i));
	}//End For
	
	sql ="select grupo, usuario, nombre, observacion,user_id from tbl_pla_ct_usuario_x_grupo where grupo="+id;
	al = SQLMgr.getDataList(sql);
	
	lastLineUsuario = al.size();	
	for (int i=0; i <al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		cdo.setKey(i);
		cdo.setAction("U");
		hastusua.put(cdo.getKey(),cdo);
		vUser.addElement(cdo.getColValue("user_id"));
		
	} //End For

	}//End if Change
	
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp"%>
</head>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Grupos Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Grupos Edición - "+document.title;
<%}%>
function checkCode(usuario,i)
{
	var msg='';
	var x=0
   if(hasDBData('<%=request.getContextPath()%>','tbl_pla_ct_usuario_x_grupo','grupo=<%=id%> and usuario=\''+usuario.value+'\'','')){msg+='\n El Usuario ya existe';x++; 
	 }
	 if(msg!='')alert(''+msg+'!');
	if(x>0)	return false;
	else return true;
}
function showUserList(tab)
{
	abrir_ventana1('../common/check_user.jsp?fp=gruposPla&mode=<%=mode%>&tab='+tab+'&id=<%=id%>');
}

function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("2"))
		{
%>
	showUserList();
<%
		}
		
	}
%>
}
</script>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - MANTENIMIENTO - GRUPOS"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">
				<tr>
					<td>
					<%--Inicio del Tab Principal--%>
					<div id="dhtmlgoodies_tabView1">
					<%--Inicio del Tab1--%>
					<div class="dhtmlgoodies_aTab">
					<table width="100%" cellpadding="0" cellspacing="1">
					<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("tab","0")%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("codigo",grp.getColValue("codigo"))%>
					<%=fb.hidden("lastLineArea",""+lastLineArea)%> 
					<%=fb.hidden("lastLineUsuario",""+lastLineUsuario)%>					
				  	<%=fb.hidden("areaSize",""+hastarea.size())%> 
					<%=fb.hidden("usuariSize",""+hastusua.size())%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("code",code)%>
						<tr class="TextRow02">
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
								<table width="100%" cellpadding="1" cellspacing="0">
								<tr class="TextPanel">
									<td width="95%">&nbsp;Generales de un Grupo</td>
									<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
								</tr>
								</table>
							</td>
						</tr>
						<tr id="panel0">
							<td>
								<table width="100%" cellpadding="1" cellspacing="1">
								<tr class="TextRow01">
									<td width="15%">C&oacute;digo</td>
									<td width="85%"><%=grp.getColValue("codigo")%></td>				
								</tr>							
								<tr class="TextRow01">
									<td>Descripci&oacute;n</td>
									<td><%=fb.textBox("descripcion",grp.getColValue("descripcion"),true,false,false,50)%></td>
								</tr>					
								</table>
							</td>
						</tr>
						<tr>
							<td>
							<jsp:include page="../common/bitacora.jsp" flush="true">
							<jsp:param name="audTable" value="tbl_pla_ct_grupo"></jsp:param>
							<jsp:param name="audFilter" value="<%="codigo="+id%>"></jsp:param>
							</jsp:include>
							</td>
						</tr>
						<tr class="TextRow02">
						<td align="right"> 
						Opciones de Guardar: <%=fb.radio("saveOption","N")%>
						Crear Otro  		 <%=fb.radio("saveOption","O")%>
						Mantener Abierto 	 <%=fb.radio("saveOption","C",true,false,false)%>
						Cerrar 				 <%=fb.submit("save","Guardar",true,false)%> 
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> 
						</td>
						</tr>
				  
					<%=fb.formEnd(true)%>	
					</table>
					</div>
					
					<%--Tab1 de Area de Trabajo por Grupo--%>
				<!--Las opciones de Alto Riesgo, Pago x Quincena Completa y Pago por Turno
				Solamente se pueden accesar en Planilla(Recurso Humanos)
				-->
					<div class="dhtmlgoodies_aTab">
					<table width="100%" cellpadding="0" cellspacing="1">
					<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("tab","1")%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("codigo",grp.getColValue("codigo"))%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("lastLineArea",""+lastLineArea)%> 
					<%=fb.hidden("lastLineUsuario",""+lastLineUsuario)%>					
				  	<%=fb.hidden("areaSize",""+hastarea.size())%> 
					<%=fb.hidden("usuariSize",""+hastusua.size())%>
					<%=fb.hidden("code",code)%>
					<tr class="TextRow02">
						 <td>&nbsp;</td>
					</tr>
					<tr>
						<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Areas de Trabajo por Grupo</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>								
							</table>
						</td>
					</tr>
					<tr id="panel1">
						<td>
							<table width="100%" cellpadding="1" cellspacing="1">
								<tr>
									<td colspan="9">
										<table width="100%" cellpadding="1" cellspacing="1">
											<tr class="TextRow01">
											<td width="15%">&nbsp;C&oacute;d. de Grupo</td>
											<td width="85%">&nbsp;<%=grp.getColValue("codigo")%></td>											
											</tr>
											<tr class="TextRow01">
											<td>&nbsp;Descripci&oacute;n</td>
											<td>&nbsp;<%=grp.getColValue("descripcion")%></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr class="TextHeader" align="center">
									<td width="8%" align="center">C&oacute;d.</td>
									<td width="25%">Nombre</td>				
									<td width="10%" align="center">Estado</td>
									<!--Esta 3 columnas tienen q ser contralados 
									por medio de seguridad ya q no son visibles para todos los usuarios.
									Solamente se pueden accesar desde Planilla(Recursos Humanos)-->
									<td width="10%" align="center">Abreviatura</td>
									<td width="10%">Nombre Corto</td>
									<td width="10%" align="center">Alto Riesgo</td>
									<td width="12%">Pago X Quinc. Completa</td>
									<td width="10%">Pago X Turno</td>
									<!---->
									<td width="5%" align="center"><%=fb.submit("btnagrega","+",false,false)%></td>
								</tr>
								<%
								String jsp="";
								//if(hastarea.size()>0)
								al=CmnMgr.reverseRecords(hastarea);
								for(int i=0; i<hastarea.size();i++)
								{
								key = al.get(i).toString();
								CommonDataObject cdos= (CommonDataObject) hastarea.get(key);	
								String color="";
								if (i%2 == 0) color = "TextRow02";
								else color = "TextRow01";
								%>
								<%=fb.hidden("key"+i,key)%>
                <%=fb.hidden("usuario_creacion"+i,cdos.getColValue("usuario_creacion"))%>
                <%=fb.hidden("fecha_creacion"+i,cdos.getColValue("fecha_creacion"))%>
								<tr class="<%=color%>">
								<td>
								<%=fb.intBox("code"+i,cdos.getColValue("codigo"),true,false,true,2,3,"Text10",null,null)%></td>
								<td><%=fb.textBox("nombre"+i,cdos.getColValue("nombre"),true,false,false,35,60,"Text10",null,null)%></td>
								<td><%=fb.select("estado"+i,"1=Activa,2=Inactiva",cdos.getColValue("estado"),false,false,0,"Text10",null,null)%></td>
								<td align="center"><%=fb.textBox("abreviatura"+i,cdos.getColValue("abreviatura"),true,false,false,3,3,"Text10",null,null)%></td>
								<td align="center"><%=fb.textBox("nombre_corto"+i,cdos.getColValue("nombre_corto"),true,false,false,5,5,"Text10",null,null)%></td>
								
								
								<td><%=fb.checkbox("area_alto_riesgo"+i,"S",(cdos.getColValue("area_alto_riesgo") != null && cdos.getColValue("area_alto_riesgo").trim().equalsIgnoreCase("S")),false)%></td>
								<td><%=fb.decBox("valor_alto_riesgo_quinc"+i,cdos.getColValue("valor_alto_riesgo_quinc"),false,false,false,5,3.2,"Text10",null,null)%></td>
								<td><%=fb.decBox("valor_alto_riesgo_turno"+i,cdos.getColValue("valor_alto_riesgo_turno"),false,false,false,5,3.2,"Text10",null,null)%></td>
								<td align="center"><%=fb.submit("remover"+i,"X",false,false)%></td>
								</tr>
								<%
								//jsp += "if(document."+fb.getFormName()+".code"+i+".value=='')error--;";
								//jsp += "if(document."+fb.getFormName()+".nombre"+i+".value=='')error--;";
								}
								fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jsp+"}");	
								%>
							</table>
						</td>
					</tr>
					<tr class="TextRow02">
					   <td align="right"> Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>	
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> 
						</td>
                    </tr>
					<%=fb.formEnd(true)%>	
					</table>
					</div>
					
					<%--Tab2 Usuario por Grupo--%>
					<div class="dhtmlgoodies_aTab">
					<table width="100%" cellpadding="0" cellspacing="1">
					<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%fb.appendJsValidation("if(document.form2.baction.value!='Guardar')return true;");%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("tab","2")%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("id",id)%>
					<%=fb.hidden("codigo",grp.getColValue("codigo"))%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("lastLineArea",""+lastLineArea)%> 
					<%=fb.hidden("lastLineUsuario",""+lastLineUsuario)%>					
				  	<%=fb.hidden("areaSize",""+hastarea.size())%> 
					<%=fb.hidden("usuariSize",""+hastusua.size())%>
					<%=fb.hidden("code",code)%>
					<tr class="TextRow02">
						 <td>&nbsp;</td>
					</tr>
					<tr>
						<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
							<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Areas de Trabajo por Grupo</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
							</tr>
							</table>
						</td>
					</tr>
					<tr id="panel2">
						<td>
							<table width="100%" cellpadding="1" cellspacing="1">
								<tr>
									<td colspan="4">
										<table width="100%" cellpadding="1" cellspacing="1">
											<tr class="TextRow01">
											<td width="15%">&nbsp;C&oacute;d. de Grupo</td>
											<td width="85%">&nbsp;<%=grp.getColValue("codigo")%></td>											
											</tr>
											<tr class="TextRow01">
											<td>&nbsp;Descripci&oacute;n</td>
											<td>&nbsp;<%=grp.getColValue("descripcion")%></td>
											</tr>
										</table>
									</td>
								</tr>
								<tr class="TextHeader" align="center">
									<td width="15%" align="center">ID</td>
									<td width="40%">Nombre del Usuario</td>				
									<td width="40%" align="center">Observaci&oacute;n</td>
									<td width="5%" align="center"><%=fb.submit("addUser","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Usuarios")%></td>
								</tr>	
								<%
								String jsps="";
								//if(hastusua.size()>0)
								al=CmnMgr.reverseRecords(hastusua);
								for(int i=0; i<hastusua.size();i++)
								{
								key = al.get(i).toString();
								CommonDataObject cdo= (CommonDataObject) hastusua.get(key);	
								String color="";
								if (i%2 == 0) color = "TextRow02";
								else color="TextRow01";
								%>
								<%=fb.hidden("key"+i,cdo.getColValue("key"))%>
								<%=fb.hidden("remove"+i,"")%>
								<%=fb.hidden("action"+i,""+cdo.getAction())%>	
								<%=fb.hidden("user_id"+i,cdo.getColValue("user_id"))%>	
								<%=fb.hidden("user"+i,cdo.getColValue("usuario"))%>							
								<%=fb.hidden("nombre"+i,cdo.getColValue("nombre"))%>
								<%if(!cdo.getAction().trim().equals("D")){%>
								<tr class="<%=color%>">
								<td>
								<%=fb.textBox("usuario"+i,cdo.getColValue("usuario"),false,true,false,20,240,null,null,"")%>
								</td>
								<td><%=fb.textBox("name"+i,cdo.getColValue("nombre"),false,true,false,50,240,"Text10",null,null)%></td>
								<td><%=fb.textBox("observacion"+i,cdo.getColValue("observacion"),false,false,false,60,240,"Text10",null,null)%></td>
								<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
								</tr>
								<%}%>
								<%
								jsps += "if(document."+fb.getFormName()+".usuario"+i+".value=='')error--;";
								jsps += "if(document."+fb.getFormName()+".nombre"+i+".value=='')error--;";
								}
								fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+jsps+"}");	
								%>
							</table>
						</td>
					</tr>
					<tr class="TextRow02">
					   <td align="right"> Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> 
						</td>
                    </tr>		
					 <% // fb.appendJsValidation("\n\tif (!checkCode()) error++;\n"); %>			
					<%=fb.formEnd(true)%>	
					</table>
					</div>
					
					</div>
<script type="text/javascript">
<%
if(mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Grupo'),0,'100%','');
<%
}
else 
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Grupo','Area de Trabajo X Grupo','Usuario X Grupo'),<%=tab%>,'100%','');
<%
}
%>
</script>
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
	String baction = request.getParameter("baction");
	if(tab.equals("0")) //Tab0 de Grupo
	{
		 grp = new CommonDataObject();
	
		grp.setTableName("TBL_PLA_CT_GRUPO");
		grp.addColValue("DESCRIPCION",request.getParameter("descripcion")); 
		grp.addColValue("FECHA_MODIFICACION",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		grp.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));
			
		if (mode.equalsIgnoreCase("add"))
		{  
			grp.setAutoIncCol("codigo"); 
			grp.addColValue("COMPANIA",(String) session.getAttribute("_companyId"));
		grp.addColValue("FECHA_CREACION",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		grp.addColValue("USUARIO_CREACION",(String) session.getAttribute("_userName")); 
	 
		SQLMgr.insert(grp);
		}
		else
		{
		 grp.setWhereClause("codigo="+request.getParameter("id"));
		SQLMgr.update(grp);
		}
	
	}//End If del Tab0 de Grupo

	else if(tab.equals("1"))//Area de Grupo
	{
		ArrayList list= new ArrayList();
		int areaSize = Integer.parseInt(request.getParameter("areaSize"));
		String itemRemoved = "";
		//al.clear();
		for (int i=0; i<areaSize; i++)
		{
			CommonDataObject cdo= new CommonDataObject();
			//cdo.setTableName("TBL_PLA_CT_AREA_X_GRUPO");
			//cdo.setWhereClause("COMPANIA="+(String) session.getAttribute("_companyId")+" and GRUPO="+id);
			cdo.addColValue("GRUPO",id);
			cdo.addColValue("COMPANIA",(String) session.getAttribute("_companyId"));
			cdo.addColValue("NOMBRE",request.getParameter("nombre"+i));
			cdo.addColValue("codigo",request.getParameter("code"+i));
			cdo.addColValue("ESTADO",request.getParameter("estado"+i));
			cdo.addColValue("abreviatura",request.getParameter("abreviatura"+i));
			cdo.addColValue("nombre_corto",request.getParameter("nombre_corto"+i));
			cdo.addColValue("USUARIO_CREACION",request.getParameter("usuario_creacion"+i));
			//cdo.addColValue("FECHA_CREACION",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			//cdo.addColValue("FECHA_MODIFICACION",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			cdo.addColValue("USUARIO_MODIFICACION",(String) session.getAttribute("_userName"));		
			cdo.addColValue("AREA_ALTO_RIESGO",(request.getParameter("area_alto_riesgo"+i)==null)?"N":"S");
			cdo.addColValue("VALOR_ALTO_RIESGO_QUINC",request.getParameter("valor_alto_riesgo_quinc"+i));   
			cdo.addColValue("VALOR_ALTO_RIESGO_TURNO",request.getParameter("valor_alto_riesgo_turno"+i));
			cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and GRUPO="+request.getParameter("id"));
			cdo.setAutoIncCol("codigo");
			key=request.getParameter("key"+i);
			System.out.println("++++++++++++++++buttonremover="+request.getParameter("remover"+i)+"key="+request.getParameter("key"+i));
			if(request.getParameter("remover"+i)==null)
			{
				try
				{
					hastarea.put(key,cdo);
					list.add(cdo);	
				}//End  try	
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			} else itemRemoved=key;	
		}//End for
	
		if(!itemRemoved.equals(""))
		{
			hastarea.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&lastLineArea="+lastLineArea+"&lastLineUsuario="+lastLineUsuario);
			return;
		}
		System.out.println("+++++++++++agregar+++++++++++++++"+request.getParameter("btnagrega"));
	
		if(request.getParameter("btnagrega")!=null)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("codigo","0");
			cdo.addColValue("grupo","0");
			cdo.addColValue("USUARIO_CREACION",(String) session.getAttribute("_userName"));
			lastLineArea++;
			if(lastLineArea < 10) key = "00" + lastLineArea;
			else if(lastLineArea <100) key = "0" +lastLineArea;
			else key = "" + lastLineArea;
			hastarea.put(key,cdo);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&lastLineArea="+lastLineArea+"&lastLineUsuario="+lastLineUsuario);
			return;
		}//End 
		AEmpMgr.addAreaXGrupo(list);	
		sql = "select a.codigo value_col, a.codigo||'-'||a.nombre label_col, b.compania||'-'||b.codigo key_col from tbl_pla_ct_area_x_grupo a, tbl_pla_ct_grupo b where a.compania = b.compania and a.grupo = b.codigo and a.estado = 1";
		IXml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+"/areaXGrupo.xml", sql);
		SQLMgr.setErrCode(AEmpMgr.getErrCode());
		SQLMgr.setErrMsg(AEmpMgr.getErrMsg());
	}//End if del Tab de Area de Grupo
	else if(tab.equals("2"))// tab de usuario
	{
		ArrayList list= new ArrayList();
		int usuariSize = Integer.parseInt(request.getParameter("usuariSize"));
		String itemRemoved = "";
		
		list.clear();
		hastusua.clear();
		vUser.clear();
		for (int i=0; i<usuariSize; i++)
		{
			CommonDataObject cdo= new CommonDataObject();
			cdo.setTableName("TBL_PLA_CT_USUARIO_X_GRUPO");
			cdo.setWhereClause("GRUPO="+id+" and user_id="+request.getParameter("user_id"+i));
			cdo.addColValue("GRUPO",id);
			cdo.addColValue("usuario",request.getParameter("user"+i));
			cdo.addColValue("user_id",request.getParameter("user_id"+i));
			cdo.addColValue("nombre",request.getParameter("nombre"+i));
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));
			key=cdo.getKey();
			
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) {
				itemRemoved = key;
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X")) {
				try {
					hastusua.put(cdo.getKey(),cdo);
					list.add(cdo);
					if (!cdo.getAction().equalsIgnoreCase("X")&&!cdo.getAction().equalsIgnoreCase("D"))vUser.addElement(request.getParameter("user_id"+i));
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}
		}//End For
		if(!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&lastLineArea="+lastLineArea+"&lastLineUsuario="+lastLineUsuario);
			return;
		}
		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&type=2&mode="+mode+"&id="+id+"&lastLineArea="+lastLineArea+"&lastLineUsuario="+lastLineUsuario);
			return;
		}
		
		if (list.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("TBL_PLA_CT_USUARIO_X_GRUPO");
			cdo.setWhereClause("GRUPO="+id);
			cdo.setAction("I");
			list.add(cdo);
		}
		SQLMgr.saveList(list,true,false);
	}//end if de Tab de Usuario
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/areasalto_riesgo_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/areasalto_riesgo_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/areasalto_riesgo_list.jsp';
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
	window.close();
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>