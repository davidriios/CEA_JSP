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
<jsp:useBean id="iCPT" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCPT" scope="session" class="java.util.Vector" />
<%


SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String estadoPerfil = request.getParameter("estadoPerfil");
String key = "";
String fp = request.getParameter("fp");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName();

ArrayList al = new ArrayList();

int CPTlastLineNo = 0;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (fp == null) fp = "profileCPT";
if (id==null) id = "";
if (estadoPerfil == null) estadoPerfil = "";

// TODO: REMOVE
//iCPT.clear();
//vCPT.clear();

if (request.getParameter("CPTlastLineNo") != null) CPTlastLineNo = Integer.parseInt(request.getParameter("CPTlastLineNo"));

CommonDataObject cdoCPT = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	CommonDataObject cdo = new CommonDataObject();

	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdoCPT.addColValue("id","0");

		iCPT.clear();
		vCPT.clear();
	}
	else
	{
		if (id.trim().equals("")) throw new Exception("El Perfil CPT no es válido. Por favor intente nuevamente!");

		sql = "select id, nombre, tipo, estado, observacion, usuario_creacion usuarioCreacion, to_char(fecha_creacion ,'dd/mm/yyyy hh12:mi:ss am') fechaCreacion, usuario_modificacion usuarioModificacion, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fechaModificacion from tbl_cdc_cpt_profile where id="+id;

		cdoCPT = SQLMgr.getData(sql);

		if (change == null){
			sql = "select p.id_profile, p.id_cpt, p.observacion, d.descripcion desccpt, p.usuario_creacion usuariocreacion, p.fecha_creacion fechacreacion, nvl((select join(cursor(select cds2.codigo||'='||cds2.descripcion||' - Precio : '||decode(aa.precio,null,0,aa.precio)||' Costo: '||decode(aa.costo,null,0,aa.costo) from tbl_cds_procedimiento_x_cds cc,tbl_cds_centro_Servicio cds2 ,tbl_cds_procedimiento aa where cC.COD_CENTRO_SERVICIO = CDS2.CODIGO and CDS2.REPORTA_A in (select codigo from tbl_cds_centro_servicio where interfaz = decode('"+cdoCPT.getColValue("tipo")+"','L','LIS','R','RIS','B','BDS') ) and cc.cod_procedimiento=aa.codigo and cc.cod_procedimiento=d.codigo and aa.estado='A'),',') from dual),' ') as centros,	cds.descripcion centroServicioDesc, cds.codigo cod_cds from tbl_cdc_cpt_x_profiles p, tbl_cds_procedimiento d, tbl_cds_procedimiento_x_cds c, tbl_cds_centro_servicio cds where p.id_cpt = d.codigo and d.codigo = c.cod_procedimiento and cds.codigo = c.cod_centro_servicio and P.COD_CDS = C.COD_CENTRO_SERVICIO and p.id_profile = "+id;

		   al = SQLMgr.getDataList(sql);

		   iCPT.clear();
		   vCPT.clear();

		   CPTlastLineNo = al.size();

		   for (int i=1; i<=al.size(); i++){
				cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					iCPT.put(key, cdo);
					vCPT.addElement(cdo.getColValue("id_cpt"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}//for i
		}// change == null
	}

	if (cdoCPT == null) cdoCPT = new CommonDataObject();

	System.out.println(":::::::::::::::::::::::::::::::: MODE = "+mode);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
function doAction(){
  <%if (request.getParameter("type") != null){%>
	<%if (tab.equals("1")){%>
	   showProcedimientoList();
	<%}%>
  <%}%>

}
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Perfil CPT - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Perfil CPT - Edici\363n - "+document.title;
<%}%>

function _doSubmit(fName){
  if (canSubmit()){
    document.forms[fName].submit();
  }else{
  	CBMSG.warning("Por favor ingrese el nombre del perfil!");
  }
}

function showProcedimientoList(){
	abrir_ventana1('../common/check_procedimiento.jsp?fp=<%=fp%>&mode=<%=mode%>&id=<%=id%>&CPTlastLineNo=<%=CPTlastLineNo%>&tab=<%=tab%>&tipoProfil='+document.form0.tipoPerfil.value);
}

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function canSubmit(){
	return (document.form0.nombre.value!="");
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Perfil CPT"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<!-- MAIN DIV STARTS HERE -->
			<div id = "dhtmlgoodies_tabView1">

			<!-- TAB0 DIV STARTS HERE-->
			<div class = "dhtmlgoodies_aTab">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
		    <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fp",fp)%>
			<%=fb.hidden("codigo",cdoCPT.getColValue("codigo"))%>
			<%=fb.hidden("tab","0")%>
			<%=fb.hidden("nombreCPT",cdoCPT.getColValue("nombre"))%>
			<%=fb.hidden("id",""+id)%>
			<%=fb.hidden("CPTsize",""+iCPT.size())%>
			<%=fb.hidden("CPTlastLineNo",""+CPTlastLineNo)%>
			<%=fb.hidden("fecha_creacion",cdoCPT.getColValue("fechaCreacion"))%>
			<%=fb.hidden("usuario_creacion",cdoCPT.getColValue("usuarioCreacion"))%>
			<%=fb.hidden("id_profile",id)%>
				<tr class="TextHeader">
					<td colspan="2" align="left">&nbsp;<cellbytelabel id="1">Perfil CPT</cellbytelabel></td>
				</tr>
				<tr class="TextRow01" >
					<td width="20%">&nbsp;<cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
					<td width="80%">&nbsp;<%=cdoCPT.getColValue("id")%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Nombre</cellbytelabel></td>
					<td>&nbsp;<%=fb.textBox("nombre",cdoCPT.getColValue("nombre"),true,false,false,45)%></td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="3">Tipo Perfil</cellbytelabel></td>
					<td>&nbsp;<%=fb.select("tipoPerfil","I=Imagenolog\355a,L=Laboratorio,B=Banco de Sangre",cdoCPT.getColValue("tipo"),false,false,0,null,"","")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
						<%=fb.select("estado","A=Activo,I=Inactivo",cdoCPT.getColValue("estado"),false,false,0,null,"","")%>
					</td>
				</tr>
				<tr class="TextRow01" >
					<td>&nbsp;<cellbytelabel id="4">Observaciones</cellbytelabel></td>
					<td>&nbsp;<%=fb.textarea("observacion",cdoCPT.getColValue("observacion"),false,false,false,100,2,1000,null,null,null)%>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right" colspan="2">
					<% String form = "'"+fb.getFormName()+"'";%>
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value); _doSubmit("+form+")\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<tr>
					<td colspan="2">&nbsp;</td>
				</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

			</table>
		   </div><!-- TAB0 DIV ENDS HERE -->

		   <!-- TAB1 DIV STARTS HERE -->
		   <div class="dhtmlgoodies_aTab">

				  <table align="center" width="100%" cellpadding="0" cellspacing="1">
				    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("mode",mode)%>
					<%=fb.hidden("baction","")%>
					<%=fb.hidden("fp",fp)%>
					<%=fb.hidden("codigo","")%>
					<%=fb.hidden("tab","1")%>
					<%=fb.hidden("id",""+id)%>
					<%=fb.hidden("CPTsize",""+iCPT.size())%>
					<%=fb.hidden("CPTlastLineNo",""+CPTlastLineNo)%>
					<%=fb.hidden("id_profile",id)%>
					 <tr class="TextHeader">
						  <td colspan="5" align="left">&nbsp;Procedimientos</td>
					 </tr>
					 <tr class="TextHeader01">
					 	<td colspan="5">[<%=id%>]<%=cdoCPT.getColValue("nombre")%></td>
					 </tr>
					 <tr class="TextHeader02">
					 	<td width="10%">Id Procedimiento</td>
						<td width="18%">CDS</td>
						<td width="36%">Descripci&oacute;n</td>
						<td width="25%">Observaciones</td>
						<td width="5%" align="center">
						<% form = "'"+fb.getFormName()+"'";%>
						<%=fb.submit("addDiagnostico","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Diagnósticos")%>
						</td>
					 </tr>

					<%
						al = CmnMgr.reverseRecords(iCPT);
						for (int i=1; i<=iCPT.size(); i++)
						{
							key = al.get(i - 1).toString();
							CommonDataObject cdoCTP = (CommonDataObject) iCPT.get(key);
					%>
					<tr class="TextRow01">
						<td><%=cdoCTP.getColValue("id_cpt")%></td>
						<td><%//=cdoCTP.getColValue("centroServicioDesc")%>
						<%=fb.select("alCentros"+i,cdoCTP.getColValue("centros"),cdoCTP.getColValue("cod_cds"),true,false,false,0,"Text10",null,"","","S")%>
						</td>
						<td><%=cdoCTP.getColValue("descCPT")%></td>
						<td>
						<%=fb.textarea("observacion"+i,cdoCTP.getColValue("observacion"),false,false,false,30,2)%>
						</td>
						<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem("+form+","+i+")\"","Eliminar Diagnósticos")%></td>
					</tr>
					<%=fb.hidden("key"+i,cdoCTP.getColValue("key"))%>
					<%=fb.hidden("remove"+i,"")%>
					<%//=fb.hidden("observacion"+i,cdoCTP.getColValue("observacion"))%>
					<%=fb.hidden("id_cpt"+i,cdoCTP.getColValue("id_cpt"))%>
					<%=fb.hidden("descCPT"+i,cdoCTP.getColValue("descCPT"))%>
					<%=fb.hidden("cod_cds"+i,cdoCTP.getColValue("cod_cds"))%>
					<%=fb.hidden("centros"+i,cdoCTP.getColValue("centros"))%>					
					<%=fb.hidden("centroServicioDesc"+i,cdoCTP.getColValue("centroServicioDesc"))%>
					 <%  }  %>


				 <tr class="TextRow02">
					<td align="right" colspan="5">
						<cellbytelabel id="10">Opciones de Guardar</cellbytelabel>:&nbsp;&nbsp;
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="11">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="12">Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
					 <%=fb.formEnd(true)%>
			      </table>

		   </div><!-- TAB1 DIV ENDS HERE -->

		   </div><!-- MAIN DIV ENDS HERE -->
		</td>
	</tr>
</table>
<script type="text/javascript">
<%
String disabledTab = "";
String tabLabel = "'Perfil CPT'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Procedimientos'";
if (estadoPerfil.trim().equals("I")) disabledTab = "'1'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','',null,null,null,[<%=disabledTab%>]);
//initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
    String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");

	if (tab.equals("0")){
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_cdc_cpt_profile");
		cdo.addColValue("nombre",request.getParameter("nombre"));
		cdo.addColValue("tipo",request.getParameter("tipoPerfil"));
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("observacion",request.getParameter("observacion"));

		cdo.addColValue("usuario_modificacion",cUserName);
		cdo.addColValue("fecha_modificacion",cDate);

	  if (mode.equalsIgnoreCase("add"))
	  {
		cdo.addColValue("usuario_creacion",cUserName);
		cdo.addColValue("fecha_creacion",cDate);

		cdo.setAutoIncCol("id");
		cdo.addPkColValue("id","");

		SQLMgr.insert(cdo);

		id = SQLMgr.getPkColValue("id");
	  }
	  else
	  {

		cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"));
		cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"));

		cdo.setWhereClause("id="+request.getParameter("id_profile"));

		SQLMgr.update(cdo);
	  }

    }
  	else if (tab.equals("1")) //PROCEDIMIENTOS
	{
		int size = 0;
		if (request.getParameter("CPTsize") != null) size = Integer.parseInt(request.getParameter("CPTsize"));
		String itemRemoved = "";
		al.clear();

		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_cdc_cpt_x_profiles");
			cdo.setWhereClause("id_profile="+id+"");

			cdo.addColValue("id_cpt",request.getParameter("id_cpt"+i));
			cdo.addColValue("id_profile",request.getParameter("id_profile"));
			cdo.addColValue("usuario_creacion",cUserName);
			cdo.addColValue("fecha_creacion",cDate);
			cdo.addColValue("observacion",request.getParameter("observacion"+i));
			cdo.addColValue("descCPT",request.getParameter("descCPT"+i));

			cdo.addColValue("cod_cds",request.getParameter("alCentros"+i));
			//cdo.addColValue("cod_cds",request.getParameter("cod_cds"+i));
			cdo.addColValue("centros",request.getParameter("centros"+i));
			cdo.addColValue("centroServicioDesc",request.getParameter("centroServicioDesc"+i));

			cdo.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
				itemRemoved = cdo.getColValue("key");
			else
			{
				try
				{
					iCPT.put(cdo.getColValue("key"),cdo);
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}
		if (!itemRemoved.equals(""))
		{
			vCPT.remove(((CommonDataObject) iCPT.get(itemRemoved)).getColValue("id_cpt"));
    	    iCPT.remove(itemRemoved);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&CPTlastLineNo="+CPTlastLineNo+"&id="+id);
			return;
		}
		if (baction != null && baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&CPTlastLineNo="+CPTlastLineNo+"&id="+id);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_cdc_cpt_x_profiles");
			cdo.setWhereClause("id_profile="+id);

			al.add(cdo);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(al);
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
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/perfiles_cpt_list.jsp"))
	{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/enfermedad_notific_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/admision/perfiles_cpt_list.jsp';
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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.opener.location = '<%=request.getContextPath()%>/admision/perfiles_cpt_list.jsp';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fp=<%=fp%>&id=<%=id%>';
}

function editMode()
{
	window.opener.location = '<%=request.getContextPath()%>/admision/perfiles_cpt_list.jsp';
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?id=<%=id%>&mode=edit&tab=<%=tab%>&fp=<%=fp%>&estadoPerfil=<%=request.getParameter("estado")%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>