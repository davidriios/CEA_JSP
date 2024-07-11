<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
ArrayList alParam = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
CommonDataObject cdo2 = new CommonDataObject();
CommonDataObject cdo3 = new CommonDataObject();
CommonDataObject cdoParam = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String tipo = request.getParameter("tipo");
String code = request.getParameter("code");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String change = request.getParameter("change");
String eval_por = "";
String color = "";

if (mode == null || mode.equals("")) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if(code == null) code = "0";


if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	// ----------------------------------- query para el historial -------------------------------------------------- //
	sql = "select codigo, to_char(fecha,'dd/mm/yyyy') fecha, to_char(fecha,'hh12:mi:ss am') hora, usuario_creacion from tbl_sal_terapia_eval where tipo = '"+tipo+"' and pac_id="+pacId+" and admision = "+noAdmision+ " order by fecha, hora desc";
	
	al2= SQLMgr.getDataList(sql);
	
	
	// ----------------------------------- query para los parametros -------------------------------------------------- //
	StringBuffer sbSql = new StringBuffer();
	
	if(code.equals("0")){
		
	sbSql.append("select id as paramPadre, 0 as paramDet, descripcion as paramDesc, evaluable, comentable, eval_values from tbl_Sal_parametro where status = 'A' and tipo = '");
	sbSql.append(tipo);
	sbSql.append("' union all select a.param_id, a.id, a.descripcion, a.evaluable, a.comentable, a.eval_values from tbl_Sal_parametro_Det a, tbl_sal_parametro b where a.param_id = b.id and a.status = 'A' and b.status = 'A' and b.tipo = '");
	sbSql.append(tipo);
	sbSql.append("' order by 1,2");
	
	}else{
	
		sbSql.append("select id as paramPadre, 0 as paramDet, descripcion as paramDesc, evaluable, comentable, eval_values, 0 as fromEval, '' as observacion, id as paramID, 0 as evalDetId, '' as eval, id as paramDetId from tbl_Sal_parametro where status = 'A' and tipo = '");
		sbSql.append(tipo);
		sbSql.append("' union all select a.param_id, a.id, a.descripcion, a.evaluable, a.comentable, a.eval_values, e.codigo_eval, e.observacion, e.param_id, e.codigo, e.evaluacion, e.param_det_id  from tbl_Sal_parametro_Det a, tbl_sal_parametro b, tbl_sal_terapia_eval_det e where a.param_id = b.id and e.codigo_eval = ");
		sbSql.append(code);
		sbSql.append(" and a.status ='A' and b.status = 'A' and b.tipo = '");
		sbSql.append(tipo);
		sbSql.append("' and e.param_det_id = a.id order by 1,2");
	}
		
		//System.out.println("::::::::::::::::::::: "+sbSql);
	alParam = SQLMgr.getDataList(sbSql.toString());
	
	if(!code.equals("0")){
		
		StringBuffer sbSql2 = new StringBuffer();
		
		sbSql2.append("select to_char(eval.fecha,'dd/mm/yyyy') as fecha, to_char(eval.fecha,'hh12:mi am') as hora, eval.motivo_terapia, eval.usuario_creacion uc ");
		
		if(tipo.equals("ETO")){
		    sbSql2.append(" , eval.nivel_funcional_previo"); 
		}else{
		if(tipo.equals("ETF")){
		    sbSql2.append(" , eval.nivel_terapia,eval.problemas, eval.metas_recomen ");
		}
		}
		
	    sbSql2.append(" from tbl_sal_terapia_eval eval where eval.codigo = ");
		sbSql2.append(code);
		sbSql2.append(" and eval.tipo = '");
		sbSql2.append(tipo);
		sbSql2.append("' and eval.pac_id = ");
		sbSql2.append(pacId);
		sbSql2.append(" and eval.admision = ");
		sbSql2.append(noAdmision);
		
		cdo = SQLMgr.getData(sbSql2.toString());
		
		
	}
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - Enfermedades y Operaciones - '+document.title;
function doAction(){newHeight();}
function isChecked(k){eval('document.form0.observacion'+k).disabled = !eval('document.form0.aplicar'+k).checked;if (eval('document.form0.aplicar'+k).checked)eval('document.form0.observacion'+k).className = 'FormDataObjectEnabled';else eval('document.form0.observacion'+k).className = 'FormDataObjectDisabled';}
function verEval(k,mode){var fecha = eval('document.form0.fecha'+k).value ;var hora = eval('document.form0.hora'+k).value ;var code = eval('document.form0.code'+k).value ;window.location = '../expediente/exp_terapia_eval.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code='+code+'&tipo=<%=tipo%>&desc=<%=desc%>';}
function showDetail(k){var area=eval('document.form0.codParamPadre'+k).value;var obj=document.getElementById('detail'+area);if(obj.style.display == 'none'){obj.style.display = '';document.getElementById("panel"+area).innerHTML = '[-]';}else{obj.style.display = 'none';document.getElementById("panel"+area).innerHTML = '[+]';}}
function add(){window.location = '../expediente/exp_terapia_eval.jsp?&modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=tipo%>&desc=<%=desc%>';}
function printExp(){abrir_ventana('../expediente/print_exp_terapia_eval.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=tipo%>&seccion=<%=seccion%>&code=<%=code%>&desc=<%=desc%>');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
	 <td>
		<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("modeSec",modeSec)%>
			<%=fb.hidden("seccion",seccion)%>
			<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
			<%=fb.hidden("dob","")%>
			<%=fb.hidden("codPac","")%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("desc",desc)%>
            <%=fb.hidden("tipo",tipo)%>
            <%=fb.hidden("size",""+alParam.size())%>

            
 <!----------------------------   IMPRIMIENDO LA PRIMERA PARTE (HISTORAL) -------------------------->      
            <tr>
			   <td style="text-decoration:none;" colspan="3">
			     <div id="listado" width="100%" class="exp h100">
			     <div id="detListado" class="child">
			      <table width="100%" cellpadding="1" cellspacing="0">
					 <tr class="TextRow02">
						<td>&nbsp;<cellbytelabel id="1">Listado de Evaluaciones [ Terapia ]</cellbytelabel></td>
                        <td>&nbsp;</td>
                     <td align="right">
                     <%if(!modeSec.trim().equals("add")){%><a class="Link00" href="javascript:printExp()">[ <cellbytelabel id="2">Imprimir</cellbytelabel> ]</a><%}%>&nbsp;&nbsp;<%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="3">Agregar Evaluaci&oacute;n</cellbytelabel> ]</a><%}%></td>
					 </tr>
					 <tr class="TextHeader" align="center">
						<td><cellbytelabel id="4">Fecha</cellbytelabel></td>
						<td><cellbytelabel id="5">Hora</cellbytelabel></td>
						<td><cellbytelabel id="6">Evaluador</cellbytelabel></td>
					 </tr>
<%
for (int i = 1; i<=al2.size(); i++){
	 cdo2 = (CommonDataObject) al2.get(i-1);
	     color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01"; 
%>
        <%=fb.hidden("code"+i,cdo2.getColValue("codigo"))%>
		<%=fb.hidden("fecha"+i,cdo2.getColValue("fecha"))%>
		<%=fb.hidden("hora"+i,cdo2.getColValue("hora"))%>
        <%=fb.hidden("codigo"+i,cdo2.getColValue("codigo"))%>
     
  
                    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verEval(<%=i%>,'view')" align="center">
				       <td><%=cdo2.getColValue("fecha")%></td>
				       <td><%=cdo2.getColValue("hora")%></td>
				       <td><%=cdo2.getColValue("usuario_creacion")%></td>
                     </tr>   
<%
} //end for historial
%>                  </table>
					</div>
					</div>
				 </td>
			 </tr>
<!----------------------------   //   -------------------------->   
    
<tr class="TextHeader01">
<% if (tipo.equals("ETO")){%>
  <td colspan="3"> <cellbytelabel id="7">Actividades de la vida diaria</cellbytelabel></td>
<%}else if(tipo.equals("ETF")){%> 
 <td><cellbytelabel id="8">Nivel de la terapia</cellbytelabel>:</td>
<% if(code.equals("0")){%>
  <td>
  <%=fb.radio("nivel_terapia","INI",true,viewMode,false,null,null,"")%> <cellbytelabel id="9">INICIAL</cellbytelabel> &nbsp;
  <%=fb.radio("nivel_terapia","INT",false,viewMode,false,null,null,"")%> <cellbytelabel id="10">INTERMEDIO</cellbytelabel> &nbsp;
  <%=fb.radio("nivel_terapia","ALT",false,viewMode,false,null,null,"")%> <cellbytelabel id="11">ALTA</cellbytelabel>
  </td>
<%}else{%>
  <td>
  <%=fb.radio("nivel_terapia","INI",(cdo.getColValue("nivel_terapia")!=null && cdo.getColValue("nivel_terapia").equalsIgnoreCase("INI")),viewMode,false,null,null,"")%> <cellbytelabel id="9">INICIAL</cellbytelabel> &nbsp;
  <%=fb.radio("nivel_terapia","INT",(cdo.getColValue("nivel_terapia")!=null && cdo.getColValue("nivel_terapia").equalsIgnoreCase("INT")),viewMode,false,null,null,"")%> <cellbytelabel id="10">INTERMEDIO</cellbytelabel> &nbsp;
  <%=fb.radio("nivel_terapia","ALT",(cdo.getColValue("nivel_terapia")!=null && cdo.getColValue("nivel_terapia").equalsIgnoreCase("ALT")),viewMode,false,null,null,"")%> <cellbytelabel id="11">ALTA</cellbytelabel>
  </td>
 <%}%> 
  <td>&nbsp;</td> 
 <%}%>
  </tr>
	   
		<tr class="TextRow02" >
			<td><cellbytelabel id="4">Fecha</cellbytelabel>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="format" value="dd/mm/yyyy"/>
										<jsp:param name="valueOfTBox1" value="<%=(code.trim().equals("0")?cDateTime.substring(0,10):cdo.getColValue("fecha"))%>" />
										<jsp:param name="readonly" value="<%=(viewMode||mode.trim().equals("view"))?"y":"n"%>"/>
										</jsp:include></td>

			 <td>
										<cellbytelabel id="5">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="format" value="hh12:mi:ss am"/>
										<jsp:param name="nameOfTBox1" value="hora" />
										<jsp:param name="valueOfTBox1" value="<%=(code.trim().equals("0")?cDateTime.substring(11):cdo.getColValue("hora"))%>" />
										<jsp:param name="readonly" value="<%=(viewMode||mode.trim().equals("view"))?"y":"n"%>"/>
										</jsp:include></td>
                                        <td>&nbsp;</td>
		</tr>
        
        <%
		if(code.trim().equals("0")){
			eval_por = UserDet.getUserName()+" ("+UserDet.getName()+" )";
		}else
		if(!code.trim().equals("0")){
			eval_por = cdo.getColValue("uc");
		}else{
			eval_por = UserDet.getUserName()+" ("+UserDet.getName()+" )";
		}
		%>
        
        <tr class="TextRow01">
          <td><cellbytelabel id="12">Evaluado por</cellbytelabel></td> 
          <td><%=fb.textBox("evaluado_por",eval_por,true,false,viewMode,60,"Text10","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        <tr class="TextRow01">
          <td><cellbytelabel id="13">Motivo de Intervenci&oacute;n de Terapia Ocupacional</cellbytelabel></td> 
          <td><%=fb.textarea("motivo_terapia",cdo.getColValue("motivo_terapia"),false,false,viewMode,40,2,200,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        
        <% if(tipo.trim().equals("ETO")){%>
        <tr class="TextRow01">
          <td><cellbytelabel id="24">Nivel Funcional previo a la hospitalizaci&oacute;n</cellbytelabel></td> 
          <td><%=fb.textarea("nivel_previo",cdo.getColValue("nivel_funcional_previo"),false,false,viewMode,40,2,200,"","","")%>         <td>&nbsp;</td> 
        </tr>
		<%
		  } //if tipo is ETO
		%> 
     
       <tr>
       <td colspan="3">
         <table width="100%" cellpadding="1" cellspacing="1">
      
      <tr class="TextHeader">
           <td width="60%"><cellbytelabel id="15">Contraindicaciones/Precauciones</cellbytelabel></td>
           <td width="10%" align="center"><cellbytelabel id="16">Evaluaci&oacute;n</cellbytelabel></td>
           <td width="30%" align="center"><cellbytelabel id="17">Comentarios</cellbytelabel></td>
        </tr>
      
        <%
		String paramPadre = "", paramDet = "";
		for(int param = 0; param<alParam.size(); param++){
			cdoParam = (CommonDataObject) alParam.get(param);
	        if (cdoParam.getColValue("paramDet").equals("0")){
			   color = "TextRow01";
			 }else{
			   color = "TextRow02";
			 }			 
		%>
        
        <%=fb.hidden("codParamPadre"+param,cdoParam.getColValue("paramPadre"))%>
        <%=fb.hidden("codParamDet"+param,cdoParam.getColValue("paramDet"))%>
        
        <% if(cdoParam.getColValue("comentable").equalsIgnoreCase("N")){%>
	         <%=fb.hidden("observacion"+param, cdoParam.getColValue("observacion"))%>
		     <%=fb.hidden("evaluacion"+param, cdoParam.getColValue("observacion"))%>
	    <%}%>
     
         <% if(paramPadre.equals(cdoParam.getColValue("paramPadre"))){%>
         
         <!----------------------------   IMPRIMIENDO LOS PARAAMETROD HIJOS -------------------------->   
           <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
           <td><%=cdoParam.getColValue("paramDesc")%></td>
           <td align="center"><%=(cdoParam.getColValue("evaluable").equalsIgnoreCase("S"))?fb.select("evaluacion"+param,cdoParam.getColValue("eval_values"),cdoParam.getColValue("eval"),false,viewMode,0,null,null,null,null,"S"):""%></td>
           <td align="center"><%=(cdoParam.getColValue("comentable").equalsIgnoreCase("S"))?fb.textarea("observacion"+param, cdoParam.getColValue("observacion"),false,false, viewMode,30,1,1000,"","",""):""%></td>
           </tr> 
           <%
		   }
		    else{
	 
		       if(param != 0){
		%>               
            </table> <!-- aqui -->
			</td></tr>
        <%}%>   
        
          
 <!----------------------------   IMPRIMIENDO LOS PARAAMETROD PADRES -------------------------->   
    
          <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:showDetail(<%=param%>)">
           <td onClick=""><%=cdoParam.getColValue("paramDesc")%> &nbsp; <span style="text-decoration:none; cursor:pointer;" id="panel<%=cdoParam.getColValue("paramPadre")%>">[+]</span></td>
           <td align="center"><%=(cdoParam.getColValue("evaluable").equalsIgnoreCase("S"))?fb.select("evaluacion"+param,cdoParam.getColValue("eval_values"),cdoParam.getColValue("eval"),false,viewMode,0,null,null,null,null,"S"):""%></td>
           <td align="center"><%=(cdoParam.getColValue("comentable").equalsIgnoreCase("S"))?fb.textarea("observacion"+param, cdoParam.getColValue("observacion"),false,false, viewMode,30,1,1000,"","",""):""%></td>
           </tr> 
                   
          <tr id="detail<%=cdoParam.getColValue("paramPadre")%>" style="display:none;">
			<td colspan="3">
				<table width="100%" cellpadding="1" cellspacing="1">
        		
                <%
				} //else
        		if(param+1 == alParam.size()){%>
               </table>			
            </td>
		</tr> <!-- showhide detail -->
                 
		<%
		}
		   paramPadre = cdoParam.getColValue("paramPadre");
		}//for param
		%>
      </table>
	</td>
   </tr>
      
      <% if(tipo.equals("ETF")){%>
            
            <tr class="TextRow01">
               <td><cellbytelabel id="18">Problemas</cellbytelabel></td>
               <td><%=fb.textarea("problemas",cdo.getColValue("problemas"),false,false, viewMode,45,2,1000,"","","")%></td>
             <td>&nbsp;</td>
            </tr>
            <tr class="TextRow01">
               <td><cellbytelabel id="19">Metas/Recomndaciones</cellbytelabel></td>
               <td><%=fb.textarea("metas_recomen",cdo.getColValue("metas_recomen"),false,false, viewMode,45,2,1000,"","","")%> </td>			   <td>&nbsp;</td>
           </tr>
            <%}%>
            
            </table>
            </td>
            </tr>

		<tr class="TextRow02">
			<td colspan="3" align="right">
				<cellbytelabel id="20">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="21">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="22">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%

}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("size"));

	alParam.clear();
	al.clear();
	
	  if (modeSec.trim().equals("add")){  
		
	        cdo = new CommonDataObject();
		
		    cdo.setTableName("tbl_sal_terapia_eval");
		    cdo.addColValue("pac_id",request.getParameter("pacId"));
		    cdo.addColValue("admision",request.getParameter("noAdmision"));
			cdo.addColValue("fecha",cDateTime);
			cdo.addColValue("motivo_terapia",request.getParameter("motivo_terapia"));
			
			if(tipo.equals("ETO") && request.getParameter("nivel_previo") !=null){
			    cdo.addColValue("nivel_funcional_previo",request.getParameter("nivel_previo"));
			}

			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("usuario_creacion",request.getParameter("evaluado_por"));
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_modificacion",request.getParameter("evaluado_por"));
			cdo.addColValue("tipo",tipo);
			
			if(tipo.equals("ETF")){
			    cdo.addColValue("nivel_terapia",request.getParameter("nivel_terapia"));
				cdo.addColValue("problemas",request.getParameter("problemas"));
				cdo.addColValue("metas_recomen",request.getParameter("metas_recomen"));
			}
			

            ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());

			cdo.setAutoIncCol("codigo");
		    cdo.addPkColValue("codigo","");
			
			SQLMgr.insert(cdo);
			code = SQLMgr.getPkColValue("codigo");
			
			for(int i=0;i<size;i++){
				
		    	cdo1 = new CommonDataObject();
				
		    	cdo1.setTableName("tbl_sal_terapia_eval_det");
				
				cdo1.addColValue("codigo_eval",code);
				cdo1.addColValue("observacion",request.getParameter("observacion"+i));
				cdo1.addColValue("evaluacion",request.getParameter("evaluacion"+i));
				cdo1.addColValue("param_id",request.getParameter("codParamPadre"+i));
                cdo1.addColValue("param_det_id",request.getParameter("codParamDet"+i));
				
				cdo1.setAutoIncCol("codigo");
				
				alParam.add(cdo1);
			
			} //for
				  
		  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());		
		  SQLMgr.insertList(alParam,true,false);
		  ConMgr.clearAppCtx(null);
				
	}
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
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=request.getParameter("noAdmision")%>&desc=<%=desc%>&code=<%=code%>&tipo=<%=tipo%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
} // POST
%>