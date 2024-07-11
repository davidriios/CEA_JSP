<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" 	%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iEvoDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEvoDet" scope="session" class="java.util.Vector" />
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

CommonDataObject cdo1 = new CommonDataObject();

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String code = request.getParameter("code");
String fg = request.getParameter("fg");
String tab = request.getParameter("tab");
String toBeDisabled = request.getParameter("toBeDisabled");
String change =  request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String fStyle = "none";
String paramRespDet = "N";
try {paramRespDet =java.util.ResourceBundle.getBundle("issi").getString("auto.pram.resp");}catch(Exception e){ paramRespDet = "N";}

int detLastLineNo = 0;

boolean viewMode = false;

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (toBeDisabled == null) toBeDisabled = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getParameter("detLastLineNo") != null) detLastLineNo = Integer.parseInt(request.getParameter("detLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{   
		id = "0";
		code = "";
		iEvoDet.clear();
		vEvoDet.clear();
	}
	else
	{
		if (id == null) throw new Exception("El Codigo del Parametro no es válido. Por favor intente nuevamente!");

		sql = "select id, codigo, descripcion,tipo, orden, status, tiene_detalle from tbl_sal_evolucion_parametro where id = "+id;
		
		cdo1 = SQLMgr.getData(sql);
		
		if(paramRespDet.trim().equals("S")){
			if (change == null)
			{
				iEvoDet.clear();
				vEvoDet.clear();
				
				sql = "select d.code, d.id_param, u.codigo codigo_uso, u.descripcion uso_desc, d.descripcion, nvl(u.precio_venta,0) uso_price, d.observacion,d.frecuencia_cargo, d.frecuencia_hora,nvl(d.generar_cargo,'I')as generar_cargo,d.estado from tbl_sal_evolucion_param_det d, tbl_sal_uso u where d.compania = "+compania+" and d.id_param = "+id+" and d.codigo_uso = u.codigo(+)";
				al  = SQLMgr.getDataList(sql);

				detLastLineNo = al.size();
				for (int i=1; i<=al.size(); i++)
				{
					CommonDataObject cdo = (CommonDataObject) al.get(i-1);
					cdo.setKey(i);
					cdo.setAction("U");

					try
					{
						iEvoDet.put(cdo.getKey(), cdo);
						vEvoDet.addElement(cdo.getColValue("id_param")+"-"+cdo.getColValue("codigo_uso"));
					}
					catch(Exception e)
					{
						System.err.println(e.getMessage());
					}
				}
				
			} //change is null
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
function setBAction(fName,actionValue){document.forms[fName].baction.value = actionValue;}
function showUsoList(cInd){
  abrir_ventana("../common/check_uso.jsp?fp=evo_param_det&curIndex="+cInd+"&id=<%=id%>")
}
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Evolucion - Parametros - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Evolucion - Parametros - Edición - "+document.title;
<%}%>
function ctrlFrec(val,k){if (val=="H"){document.getElementById("frec"+k).style.display = "inline";document.getElementById("frecuencia_hora"+k).className = "FormDataObjectRequired";}else document.getElementById("frec"+k).style.display = "none";}
function checkFrec(){var  size = <%=iEvoDet.size()%>;var x=0;for(i=1;i<=size;i++){  var frecCargo = '';if(document.getElementById("frecuencia_cargo"+i))frecCargo=document.getElementById("frecuencia_cargo"+i).value;  var frecHora  = '';if(document.getElementById("frecuencia_hora"+i))frecHora= document.getElementById("frecuencia_hora"+i).value.trim();   if (frecCargo=="H" && frecHora==''){	 document.getElementById("frecuencia_hora"+i).className = "FormDataObjectRequired";    x++;  }  }  if(x>0){ alert("Por favor indique cada que hora se generará los cargos!");return false;}  else return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
	
		<!-- MAIN DIV START HERE -->
		<div id="dhtmlgoodies_tabView1">
		<!-- TAB0 DIV START HERE-->
		<div class="dhtmlgoodies_aTab">
	
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("fg",fg)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Par&aacute;metros</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="10%"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							    <td width="35%"><%=fb.textBox("codigo",cdo1.getColValue("codigo"),false,false,viewMode,20,30)%></td>														
								<td width="15%"><cellbytelabel id="3">Nombre</cellbytelabel></td>
							    <td width="40%"><%=fb.textBox("descripcion",cdo1.getColValue("descripcion"),true,false,viewMode,50,100)%></td>	
							</tr>	
							<tr class="TextRow01">
								<td><cellbytelabel id="4">Orden</cellbytelabel></td>
							    <td><%=fb.textBox("orden",cdo1.getColValue("orden"),true,false,false,5,2)%>
								<%//=fb.select("tipo","R=RESPIRATORIOS,H=HEMODINAMICOS",cdo1.getColValue("tipo"),false,viewMode,0,"Text10",null,null,"","")%></td>	
								<td><cellbytelabel id="5">Tipo</cellbytelabel></td>
							    <td><%//=fb.textBox("descripcion",cdo1.getColValue("descripcion"),true,false,false,50,100)%>
								<%String tipo="";
								if(fg.trim().equals("RE"))tipo="RE=RESPIRATORIOS";else tipo="HD=HEMODINAMICOS";
								%>
								<%=fb.select("tipo",tipo,fg,false,viewMode,0,"Text10",null,null,"","")%></td>	
							</tr>
							<tr class="TextRow01">
								<td><cellbytelabel id="6">Estado</cellbytelabel></td>
								<td colspan="2"><%=fb.select("status","A=ACTIVO,I=INACTIVO",cdo1.getColValue("status"),false,viewMode,0,"Text10",null,null,"","")%></td>
								<td><%if(fg.trim().equals("RE")){%>Utiliza detalle
								<%=fb.checkbox("tiene_detalle",cdo1.getColValue("tiene_detalle"),(cdo1.getColValue("tiene_detalle")!=null && cdo1.getColValue("tiene_detalle").equals("S")),viewMode,null,null,"","¿Tiene detalle?")%><%}%>&nbsp;
								</td>
							</tr>													
						</table>
					</td>
				</tr>
				
				
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel id="7">Opciones de Guardar</cellbytelabel>: 
						<%=fb.radio("saveOption","N")%><cellbytelabel id="8">Crear Otro</cellbytelabel> 
						<%=fb.radio("saveOption","O")%><cellbytelabel id="9">Mantener Abierto</cellbytelabel> 
						<%=fb.radio("saveOption","C",true,false,false)%><cellbytelabel id="10">Cerrar</cellbytelabel> 
						<%=fb.submit("save","Guardar",true,viewMode)%>
						<%=fb.button("cancel","Cancelar",false,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
		</table>
		
	</div> <!--END TAB0-->
	
	<%if(paramRespDet.trim().equals("S")&& (cdo1.getColValue("tiene_detalle")!=null && cdo1.getColValue("tiene_detalle").equals("S"))){%>
	
	<!-- TAB1 DIV START HERE-->
		<div class="dhtmlgoodies_aTab">
	
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>
	            <table align="center" width="100%" cellpadding="0" cellspacing="1">

				<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("tab","1")%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("codigo_param",cdo1.getColValue("codigo"))%>
				<%=fb.hidden("id",id)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("detSize",""+iEvoDet.size())%>
				<%=fb.hidden("fg",fg)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Evoluci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="2">C&oacute;digo</cellbytelabel></td>
							<td width="15%"><%=cdo1.getColValue("codigo")%></td>
							<td width="15%" align="right"><cellbytelabel id="49">Nombre</cellbytelabel></td>
							<td width="55%">
								<%=cdo1.getColValue("descripcion")%>
							</td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel>Detalle de la Evoluci&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader">
							<td width="20%"><cellbytelabel>C&oacute;digo Uso</cellbytelabel></td>
							<td width="08%"  align="right"><cellbytelabel>Tarifa x hora&nbsp;&nbsp;</cellbytelabel></td>
							<td width="25%"><cellbytelabel>&nbsp;&nbsp;Descripci&oacute;n</cellbytelabel></td>
							<td width="25%"><cellbytelabel>&nbsp;&nbsp;Frecuencia del Cargo</cellbytelabel></td>
							<td width="20%"><cellbytelabel>&nbsp;&nbsp;Observaci&oacute;n</cellbytelabel></td>
							<td width="2%"  align="center"><%=fb.submit("addDetalle","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Registro")%></td>
						</tr>
						<%
						al = CmnMgr.reverseRecords(iEvoDet);
						for (int i=1; i<=iEvoDet.size(); i++)
						{
						  key = al.get(i - 1).toString();
						  CommonDataObject cdo = (CommonDataObject) iEvoDet.get(key);
							String fechaCreacion = "fechaCreacion"+i;
							fStyle = "none";
							if (cdo.getColValue("frecuencia_cargo")!=null &&cdo.getColValue("frecuencia_cargo").equals("H") ) fStyle="";
						%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("code"+i,cdo.getColValue("code"))%>
						<%=fb.hidden("id_param"+i,cdo.getColValue("id_param"))%>
						<%=fb.hidden("codigo_param"+i,cdo.getColValue("codigo_param"))%>
						
						<%if(cdo.getAction().trim().equals("D")){%>
								<%=fb.hidden("codigo_uso"+i,cdo.getColValue("codigo_uso"))%>
								<%=fb.hidden("uso_desc"+i,cdo.getColValue("uso_desc"))%>
								<%=fb.hidden("frecuencia_cargo"+i,cdo.getColValue("frecuencia_cargo"))%>
								<%=fb.hidden("frecuencia_hora"+i,cdo.getColValue("frecuencia_hora"))%>
								<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>		
						<%}else{%>
						<tr class="TextRow01">
							<td>
							  <%=fb.textBox("codigo_uso"+i,cdo.getColValue("codigo_uso"),false,false,true,2,"Text10","","")%>
							   <%=fb.textBox("uso_desc"+i,cdo.getColValue("uso_desc"),false,false,true,20,"Text10",null,"")%>
								<%=fb.button("btnUso"+i,"...",false,false,null,null,"onClick=\"javascript:showUsoList("+i+")\"")%>
							</td>
							<td align="right"><%=fb.decBox("uso_price"+i,cdo.getColValue("uso_price"),false,false,true,10,"Text10",null,"")%>&nbsp;&nbsp;</td>
							<td>
							&nbsp;&nbsp;
							<%=fb.textBox("descripcion"+i,cdo.getColValue("descripcion"),true,false,false,32,30)%>
							</td>
							<td><%=fb.select("frecuencia_cargo"+i, "D=DIARIA (24 HORAS),H=POR HORA",cdo.getColValue("frecuencia_cargo"),false,false,0,null,null,"onchange=ctrlFrec(this.value,"+i+")")%>
						<span id="frec<%=i%>" style="display:<%=fStyle%>">&nbsp;&nbsp;Cada <%=fb.intBox("frecuencia_hora"+i,cdo.getColValue("frecuencia_hora"),false,false,false,2,2)%>
						</span>
						<%=fb.select("generar_cargo"+i, "I=AL INICIO,F=AL FINAL",cdo.getColValue("generar_cargo"),false,false,0,null,null,"")%>
					</td>
							<td>&nbsp;&nbsp;<%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,false,30,1,2000)%></td>
							<td align="center"><%=fb.select("estado"+i, "A=ACTIVO,I=INACTIVO",cdo.getColValue("estado"),false,false,0,null,null,"")%><%=(cdo.getAction().trim().equals("I"))?fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Registro"):""%></td>
						</tr>
						<%}
						}
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
				<%if(paramRespDet.trim().equals("S")){fb.appendJsValidation("if(error==0){if(!checkFrec())error++;}");}%>

<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>
			</td>
		</tr>
		</table>
		
	</div> <!--END TAB1-->
	<%}%>

	</div> <!-- END MAIN DIV-->
	
	<script type="text/javascript">
		<%
		if (mode.equalsIgnoreCase("add"))
		{
		%>
		initTabs('dhtmlgoodies_tabView1',Array('Evolución'),0,'100%','');
		<%
		}
		else
		{
			if (paramRespDet.trim().equals("S")&& (cdo1.getColValue("tiene_detalle")!=null && cdo1.getColValue("tiene_detalle").equals("S"))){
			%>
				initTabs('dhtmlgoodies_tabView1',Array('Evolución','Detalle Evolución'),<%=tab%>,'100%','',null,null,null,[<%=toBeDisabled%>]);
			<%}else{ %>
			   initTabs('dhtmlgoodies_tabView1',Array('Evolución'),0,'100%','');
			<%}%>   
		<%}%>
	</script>
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
	String saveOption = request.getParameter("saveOption"); //N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	
	if(tab.equals("0")){ // EVOLUCION

	  cdo1 = new CommonDataObject();
	  cdo1.setTableName("tbl_sal_evolucion_parametro");
	  cdo1.addColValue("descripcion",request.getParameter("descripcion")); 
	  cdo1.addColValue("tipo",request.getParameter("tipo")); 
	  cdo1.addColValue("status",request.getParameter("status")); 
	  cdo1.addColValue("orden",request.getParameter("orden"));
	  cdo1.addColValue("codigo",request.getParameter("codigo")); 
	  cdo1.addColValue("tiene_detalle",(request.getParameter("tiene_detalle")!=null?"S":"N")); 
	 
	  if (mode.equalsIgnoreCase("add"))
	  {
		
			cdo1.setAutoIncCol("id");
			cdo1.addPkColValue("id","");
			
		SQLMgr.insert(cdo1);
		id = SQLMgr.getPkColValue("id");
	  }
	  else
	  {
	   cdo1.setWhereClause("id="+request.getParameter("id"));

		SQLMgr.update(cdo1);
	  }
	} 
	else if (tab.equals("1")) //DETALLE EVOLUCION
	{
		int size = 0;
		if (request.getParameter("detSize") != null) size = Integer.parseInt(request.getParameter("detSize"));
		String itemRemoved = "";

		iEvoDet.clear();
		vEvoDet.clear();
		al.clear();
		
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_evolucion_param_det");
			cdo.setWhereClause("code="+request.getParameter("code"+i)+" and id_param="+id);
			
			if (request.getParameter("code"+i).trim().equals("0"))
			{
				cdo.setAutoIncCol("code");
				cdo.addPkColValue("code","");
				cdo.setAutoIncWhereClause("id_param="+id);
			}
			
			cdo.addColValue("code",request.getParameter("code"+i));
			cdo.addColValue("codigo_uso",request.getParameter("codigo_uso"+i));
			cdo.addColValue("id_param",id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("descripcion",IBIZEscapeChars.forSingleQuots(request.getParameter("descripcion"+i)));
			cdo.addColValue("observacion",IBIZEscapeChars.forSingleQuots(request.getParameter("observacion"+i)));
			
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("uso_desc",request.getParameter("uso_desc"+i));
			cdo.addColValue("uso_price",request.getParameter("uso_price"+i));
			cdo.addColValue("frecuencia_cargo",request.getParameter("frecuencia_cargo"+i));
			if (request.getParameter("frecuencia_cargo"+i) == null ||request.getParameter("frecuencia_cargo"+i).trim().equals("") || request.getParameter("frecuencia_cargo"+i).equals("D")) cdo.addColValue("frecuencia_hora","");
    		else cdo.addColValue("frecuencia_hora",request.getParameter("frecuencia_hora"+i));
			cdo.addColValue("generar_cargo",request.getParameter("generar_cargo"+i));
			
	
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}
					
			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iEvoDet.put(cdo.getKey(),cdo);
					vEvoDet.add(cdo.getColValue("id_param")+"-"+cdo.getColValue("codigo_uso"));
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
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&fg="+fg);
			return;
		}

		if (baction != null && baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("code","0");
			cdo.addColValue("codigo_uso","");
			cdo.addColValue("id_param",id);
			cdo.addColValue("compania",compania);
			cdo.addColValue("descripcion","");
			cdo.addColValue("observacion","");
			cdo.addColValue("frecuencia_cargo","D");
			cdo.addColValue("frecuencia_hora","");
			
			cdo.addColValue("estado","");
			cdo.addColValue("uso_desc","");
			cdo.addColValue("uso_price","");
			
			cdo.setAction("I");
			cdo.setKey(iEvoDet.size()+1);
			
			iEvoDet.put(cdo.getKey(),cdo);
			
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&fg="+fg);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_sal_evolucion_param_det");
			cdo.setWhereClause("code='"+code+"'");
			cdo.setAction("I");
			al.add(cdo); 
		}

		SQLMgr.saveList(al, true, false);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>&fg=<%=fg%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
