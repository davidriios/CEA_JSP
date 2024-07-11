<%@ page errorPage="../error.jsp"%>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iCAUT" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vCAUT" scope="session" class="java.util.Vector" />

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

CommonDataObject proc = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String cds = request.getParameter("cds");
String cama = request.getParameter("cama");
String hab = request.getParameter("hab");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String compania = (String) session.getAttribute("_companyId");

if (tab == null) tab = "0";
if (mode == null) mode = "edit";
if (cds == null ) cds = "-2";
if (cama == null ) cama = "";
if (hab == null ) hab = "";

XMLCreator xml = new XMLCreator(ConMgr);
	
if(!UserDet.getUserProfile().contains("0")){
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"almacen_x_cds_"+UserDet.getUserId()+".xml","select a.almacen as value_col, a.almacen||' - '||(select descripcion from tbl_inv_almacen where codigo_almacen=a.almacen and compania=a.compania) as label_col, a.compania||'-'||a.cds as key_col from tbl_sec_cds_almacen a,tbl_sec_user_almacen b where a.almacen=b.almacen and a.compania =b.compania  and b.ref_type='CDS' and b.user_id="+UserDet.getUserId()+" and  a.cds ="+cds+" order by a.compania,a.cds,b.user_id,a.almacen");}
	else{xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+File.separator+"almacen_x_cds_"+UserDet.getUserId()+".xml","select a.almacen as value_col, a.almacen||' - '||(select descripcion from tbl_inv_almacen where codigo_almacen=a.almacen and compania=a.compania) as label_col, a.compania||'-'||a.cds as key_col from tbl_sec_cds_almacen a where a.cds ="+cds+" order by a.compania, a.cds, a.almacen");}

int hasCAUT = 0;
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "";
		iCAUT.clear();
		vCAUT.clear();
		hasCAUT=0;
	}
	else
	{
		//if (id == null) throw new Exception("El Procedimiento no es válido. Por favor intente nuevamente!");
		
		if (change == null)
		{
	
			iCAUT.clear();
			vCAUT.clear();
	
			sql = "select id, compania, tipo_servicio, estado, codigo_item, usuario_creacion, usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, fecha_modificacion, tipo_referencia, habitacion, cama, almacen, comentario, decode(tipo_referencia,'US',(select s.descripcion from tbl_sal_uso s where s.codigo = codigo_item and s.compania = x.compania),(select a.descripcion from tbl_inv_articulo a where a.cod_articulo = x.codigo_item and a.compania=compania  )  ) descripcion,(select cc.descripcion from tbl_inv_almacen cc where cc.codigo_almacen = almacen and cc.compania = compania and rownum = 1 ) almacen_desc,familia,clase,frecuencia_cargo,frecuencia_hora from tbl_sal_cargos_automaticos x where compania = "+compania+" and cama = '"+cama+"' and habitacion = '"+hab+"' order by 1";
			al  = SQLMgr.getDataList(sql); 
			hasCAUT = al.size();
			for (int i=0; i<al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i);

				cdo.setKey(i);
				cdo.setAction("U");

				try
				{
					iCAUT.put(cdo.getKey(), cdo);	
					vCAUT.addElement(cdo.getColValue("tipo_referencia")+"-"+cdo.getColValue("codigo_item"));								
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
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
document.title = 'Inventario -  Edición - '+document.title;
function setBAction(fName,actionValue)
{   
	document.forms[fName].baction.value = actionValue;
}
function doAction(){}
function addItem(cInd){
  var tipoReferencia = document.getElementById("tipo_referencia"+cInd).value;
  var almacen = document.getElementById("almacen"+cInd).value;
  if (tipoReferencia == "US"){
     abrir_ventana("../common/check_uso.jsp?fp=cargos_aut&curIndex="+cInd+"&cCama=<%=cama%>&cHab=<%=hab%>");
  }else{
     abrir_ventana("../common/search_articulo.jsp?fp=cargos_aut&curIndex="+cInd+"&almacen="+almacen+"&id=6&cCama=<%=cama%>&cHab=<%=hab%>");
  }
}

function ctrlAlmacen(cInd){
  var tipoReferencia = document.getElementById("tipo_referencia"+cInd).value;
  var divAlmacenObj = document.getElementById("divAlmacen"+cInd);
  if (tipoReferencia !="US"){
    document.getElementById("spanCod").innerHTML="Art.";
    document.getElementById("btnAddItem"+cInd).title="Agregar Artículo";
    divAlmacenObj.style.display="block";
  }else{document.getElementById("spanCod").innerHTML="Uso";
  document.getElementById("btnAddItem"+cInd).title="Agregar código de Uso";
  divAlmacenObj.style.display="none";}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="INVENTARIO - MANTENIMIENTO - CARGOS AUTOMATICOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">

<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("CAUTSize",""+iCAUT.size())%>
<%=fb.hidden("cds",cds)%>
<%=fb.hidden("cama",cama)%>
<%=fb.hidden("hab",hab)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(70)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="28">Cargos Autom&aacute;tico</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus70" style="display:none">+</label><label id="minus70">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel70">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="7%"><cellbytelabel>Tipo</cellbytelabel></td>
							<td width="7%"><cellbytelabel>Almac&eacute;n</cellbytelabel></td>
							<td width="20%" align="left"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
							<td width="10%"><cellbytelabel>Tipo Servicio</cellbytelabel></td>	
							<td width="8%">
							<cellbytelabel>C&oacute;digo <span id="spanCod">Uso</span></cellbytelabel>
							</td>				
							<td width="8%"><cellbytelabel>Habitaci&oacute;n</cellbytelabel></td>
							<td width="7%"><cellbytelabel>Cama</cellbytelabel></td>		
															
							<td width="9%"><cellbytelabel>Estado</cellbytelabel></td>							
							<td width="28%" align="left"><cellbytelabel>Comentario</cellbytelabel></td>
							<td>
							<div class="hint hint--left" data-hint="Replicar en las otras camas">
							 <%if(hasCAUT==0){%> <%=fb.checkbox("replicar","S",false,(hasCAUT!=0),null,null,"onClick=\"\"","REPLICAR EN TODAS LAS CAMAS DE LA HABITACION")%><%}%>
							</div>
							</td>
							<td width="3%"><%=fb.submit("btnaddCA","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Cargos Automático")%></td>
						</tr>
            
						<%
						String fecha_ini = "", fecha_fin = "";
						al = CmnMgr.reverseRecords(iCAUT);				
						for (int i=0; i<iCAUT.size(); i++)
						{
						  key = al.get(i).toString();									  
						  CommonDataObject cdo = (CommonDataObject) iCAUT.get(key);
						  String display = " style='display:none;'";
						  if (cdo.getColValue("tipo_referencia").equals("AR")) display = "";
						%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("almacen_desc"+i,cdo.getColValue("almacen_desc"))%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("id"+i,cdo.getColValue("id"))%>
						<%=fb.hidden("familia"+i,cdo.getColValue("familia"))%>
						<%=fb.hidden("clase"+i,cdo.getColValue("clase"))%>
						<%=fb.hidden("frecuencia_cargo"+i,cdo.getColValue("frecuencia_cargo"))%>
						<%=fb.hidden("frecuencia_hora"+i,cdo.getColValue("frecuencia_hora"))%>
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>
						<tr class="TextRow01">
							<td align="center"><%=fb.select("tipo_referencia"+i,"US=Usos,AR=Artículos",cdo.getColValue("tipo_referencia"),false,(cdo.getColValue("codigo_item")!=null &&!cdo.getColValue("codigo_item").equals("")),0,"Text10","","onChange=\"ctrlAlmacen("+i+")\"")%></td>
							<td  align="center">
							<div<%=display%> id="divAlmacen<%=i%>">
							<%if(cdo.getColValue("codigo_item")!=null &&!cdo.getColValue("codigo_item").equals("")){%>
							  <%=cdo.getColValue("almacen_desc")%>
							  <%=fb.hidden("ignore"+i,cdo.getColValue("codigo_item"))%>
							<%}else{%>
							   <%=fb.select("almacen"+i,"","",false,false,0,null,"width:40px",null)%>
								<script language="javascript">
								loadXML('../xml/almacen_x_cds_<%=UserDet.getUserId()%>.xml','almacen<%=i%>','','VALUE_COL','LABEL_COL','<%=session.getAttribute("_companyId")%>-<%=cds%>','KEY_COL','');
								</script>
							<%}%>	
							</div>
							</td>
							<td><%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),false,false,true,40,"Text10",null,null)%></td>
							<td  align="center"><%=fb.textBox("tipo_servicio"+i,cdo.getColValue("tipo_servicio"),true,false,true,7,"Text10",null,null)%></td>
							<td><%=fb.textBox("codigo_item"+i,cdo.getColValue("codigo_item"),true,false,true,7,"Text10",null,null)%>
							<%=fb.button("btnAddItem"+i,"...",true,(cdo.getColValue("codigo_item")!=null &&!cdo.getColValue("codigo_item").equals("")),null,null,"onClick=\"javascript:addItem("+i+")\"","Agregar código de uso")%>
							</td>
							<td align="center"><%=fb.textBox("habitacion"+i,cdo.getColValue("habitacion"),false,false,true,7,"Text10",null,null)%></td>
							<td  align="center"><%=fb.textBox("cama"+i,cdo.getColValue("cama"),false,false,true,7,"Text10",null,null)%></td>
							<td  align="center"><%=fb.select("estado"+i,"A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,"Text10","","")%></td>
							<td><%=fb.textarea("comentario"+i,cdo.getColValue("comentario"),false,false,false,30,1,null,null,null)%></td>
							<td colspan="2">&nbsp;<%=(cdo.getAction().equalsIgnoreCase("I"))?fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Cargo"):""%></td>
						</tr>
						<%}
						}
						fb.appendJsValidation("if(error>0)doAction();");
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>: 
						<!--<%=fb.radio("saveOption","N")%><cellbytelabel id="16">Crear Otro </cellbytelabel>-->
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",false,false,false)%><cellbytelabel id="18">Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
//if (mode.equalsIgnoreCase("add"))
//{
%>
initTabs('dhtmlgoodies_tabView1',['Cargos Autom&aacute;ticos'],0,'100%','');
<%
/*}
else
{]*/
%>
//initTabs('dhtmlgoodies_tabView1',Array('Procedimientos','Insumos','Usos','Personal','Honorarios','Maletin Anestesia','Niveles de Precio'),<%=tab%>,'100%','');
<%
//}
%>
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	if (tab.equals("0")) //NIVEL DE PRECIO
	{
		int size = 0;
		if (request.getParameter("CAUTSize") != null) size = Integer.parseInt(request.getParameter("CAUTSize"));
		String itemRemoved = "";

		al.clear();
		iCAUT.clear();
		vCAUT.clear();
		int lineNo = 0;
		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_Sal_cargos_automaticos");  			
			cdo.setWhereClause("id = "+request.getParameter("id"+i));
			if(request.getParameter("id"+i).trim().equals("0"))
			{
				cdo.setAutoIncCol("id");
				cdo.addPkColValue("id","");
				
			}
			cdo.addColValue("id",request.getParameter("id"+i));
			cdo.addColValue("compania",compania);
			cdo.addColValue("habitacion",request.getParameter("habitacion"+i));
			cdo.addColValue("cama",request.getParameter("cama"+i));
			cdo.addColValue("tipo_servicio",request.getParameter("tipo_servicio"+i));
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("codigo_item",request.getParameter("codigo_item"+i));
			cdo.addColValue("familia",request.getParameter("familia"+i));
			cdo.addColValue("clase",request.getParameter("clase"+i));
			
			if (request.getParameter("tipo_referencia"+i).equals("AR")){
				cdo.addColValue("almacen",request.getParameter("almacen"+i));
				cdo.addColValue("almacen_desc",request.getParameter("almacen_desc"+i));
			}
			
			cdo.addColValue("comentario",request.getParameter("comentario"+i));
			cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("tipo_referencia",request.getParameter("tipo_referencia"+i));
			cdo.addColValue("frecuencia_cargo",request.getParameter("frecuencia_cargo"+i));
			cdo.addColValue("frecuencia_hora",request.getParameter("frecuencia_hora"+i));
			
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));
			
			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}
			
			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iCAUT.put(cdo.getKey(),cdo);
					vCAUT.add(cdo.getColValue("tipo_referencia")+"-"+cdo.getColValue("codigo_item"));
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&mode=edit&id="+id+"&cds="+cds+"&cama="+cama+"&hab="+hab);
			return;
		}
	
		if (baction != null && baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("id","0");
			cdo.addColValue("compania",compania);
			cdo.addColValue("habitacion",hab);
			cdo.addColValue("cama",cama);
			cdo.addColValue("tipo_servicio","");
			cdo.addColValue("estado","");
			cdo.addColValue("codigo_item","");
			cdo.addColValue("almacen","");
			cdo.addColValue("almacen_desc","");
			cdo.addColValue("comentario","");
			cdo.addColValue("familia","");
			cdo.addColValue("clase","");
			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion","");
			cdo.addColValue("fecha_modificacion","");
			cdo.addColValue("other1","");
			cdo.addColValue("other2","");
			cdo.addColValue("other3","");
			cdo.addColValue("tipo_referencia","");
			cdo.addColValue("frecuencia_cargo","D");
			cdo.addColValue("frecuencia_hora","");			
						
			cdo.setAction("I");
			cdo.setKey(iCAUT.size()+1);
			
			iCAUT.put(cdo.getKey(),cdo); 
			
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=0&type=1&mode=edit&id="+id+"&cds="+cds+"&cama="+cama+"&hab="+hab);
    	return;
		}
        
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_Sal_cargos_automaticos");
			cdo.setWhereClause("id='"+id+"'");
			cdo.setAction("I");
			al.add(cdo); 
		}
				 
		SQLMgr.saveList(al, true, false);
	
		if (request.getParameter("replicar")!=null && SQLMgr.getErrCode().equals("1")) {

			CommonDataObject param = new CommonDataObject();
			param.setSql("call sp_adm_copiar_caut (?,?,?,?)");
			param.addInStringStmtParam(1,"RT");
			param.addInStringStmtParam(2,"");
			param.addInStringStmtParam(3,cama);
			param.addInStringStmtParam(4,hab);
			param = SQLMgr.executeCallable(param,false,true);
		}
		
		
	} //END TAB 0
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>&cds=<%=cds%>&cama=<%=cama%>&hab=<%=hab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>