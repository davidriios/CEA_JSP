<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<%@ page import="issi.expediente.DetalleIntervenciones"%>
<%@ page import="issi.expediente.Intervencion"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="IntervMgr" scope="page" class="issi.expediente.IntervencionMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
IntervMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();

String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String change = request.getParameter("change");
String tipo = request.getParameter("tipo");
String codInterv = request.getParameter("cod_interv");
String codIntervDet = request.getParameter("cod_interv_det");
String descValorizacion = request.getParameter("desc_valorizacion");
String valorizacion = request.getParameter("valorizacion");
String key = "";
String sql = "";
int lastLineNo = 0;
if (fg == null) fg = "";
if (codInterv == null) codInterv = "";
if (codIntervDet == null) codIntervDet = "";
if (tipo == null) tipo = "";

if (fg.trim().equals("")) throw new Exception("No pudimos encontrar un tipo de Intervención!");

fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);
fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");

if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;

Hashtable iVal = new Hashtable();
  
if (request.getMethod().equalsIgnoreCase("GET"))
{  
    if (fg.trim().equalsIgnoreCase("intervenciones")) {
        sql = "select * from tbl_sal_intervencion_det where cod_intervencion = "+codIntervDet+" and tipo = '"+tipo+"'";
        int totIntervenciones = CmnMgr.getCount(sql);
        if (totIntervenciones > 0) mode = "edit";
        iVal.put("low", "Bajo");
        iVal.put("medium", "Medio");
        iVal.put("high", "Alto");
        iVal.put("extreme", "Extremado");
    }
    
    if (mode.equalsIgnoreCase("add")){
       if (change == null) HashDet.clear();
    } else {
        if(change == null){
            if (fg.trim().equalsIgnoreCase("valorizaciones")) {
             al = sbb.getBeanList(ConMgr.getConnection(), "SELECT codigo codigoValorizacion, descripcion descripcionValorizacion, estado estadoValorizacion, tipo tipoValorizacion, valorizacion, cod_interv codIntervValorizacion FROM tbl_sal_intervencion WHERE cod_interv = "+codInterv+" and tipo = '"+tipo+"' ORDER BY codigo ASC", DetalleIntervenciones.class); 
            }else {
              al = sbb.getBeanList(ConMgr.getConnection(), "SELECT codigo, descripcion, tipo, cod_intervencion as codigoIntervencion, mostrar_checkbox mostrarCheckbox FROM tbl_sal_intervencion_det WHERE cod_intervencion = "+codIntervDet+" and tipo = '"+tipo+"' ORDER BY codigo ASC", DetalleIntervenciones.class);
            }
            
            HashDet.clear(); 
			
            for (int i = 1; i <= al.size(); i++){
                if (i < 10) key = "00" + i;
                else if (i < 100) key = "0" + i;
                else key = "" + i;
                
                HashDet.put(key, al.get(i-1));
                lastLineNo = i;
            }
		}
    }
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Intervenciones - '+document.title;
function doSubmit(formName, btnValue){
	document.formDetalle.intervencion.value = parent.document.form1.intervencion.value; 
	document.formDetalle.tipo.value = parent.document.form1.tipo.value; 
	document.formDetalle.codigo.value = parent.document.form1.cod_interv.value; 
	document.formDetalle.estado.value = parent.document.form1.estado.value;
    <%if(fg.trim().equalsIgnoreCase("intervenciones")){%>
      setBAction(formName, btnValue);
    <%}%>
	if(formDetalleValidation()){
		document.formDetalle.submit(); 
	} else {
		parent.form1BlockButtons(false)
	}
}

function setDetalles(codValorizacion, descValorizacion, valorizacion) {
  if (!codValorizacion) alert('Por favor guarde antes de continuar!');
  else parent.showPopWin('../expediente/exp_intervencion_detalle.jsp?fg=intervenciones&mode=<%=mode%>&cod_interv_det='+codValorizacion+'&tipo=<%=tipo%>&desc_valorizacion='+descValorizacion+'&valorizacion='+valorizacion,winWidth*.95,winHeight*.85,null,null,'');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder" align="center">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction", "")%>
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("mode", mode)%>
			<%=fb.hidden("keySize",""+HashDet.size())%>
			<%=fb.hidden("codigo", "")%>
			<%=fb.hidden("estado", "")%>
			<%=fb.hidden("fg", fg)%>
			<%=fb.hidden("cod_interv", codInterv)%>
			<%=fb.hidden("cod_interv_det", codIntervDet)%>
			<%=fb.hidden("tipo", tipo)%>
			<%=fb.hidden("intervencion", "")%>
			<%=fb.hidden("ls_set", "")%>
			<%=fb.hidden("desc_valorizacion", descValorizacion)%>
			<%=fb.hidden("valorizacion", valorizacion)%>
				<tr class="TextHeader">
                    <%if(fg.trim().equalsIgnoreCase("valorizaciones")){%>
                    <td colspan="5">VALORICACIONES</td>
                    <%} else {%>
                     <td colspan="3">INTERVENCIONES PARA:&nbsp;(<%=descValorizacion%><%if(!tipo.equalsIgnoreCase("SG")){%>&nbsp;-&nbsp;<%=iVal.get(valorizacion)%><%}%>)</td>
                    <%}%>
					<td align="right">
					<%=fb.submit("addCol","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				</tr>
			    <tr class="TextHeader" align="center">
                    <%if(fg.trim().equalsIgnoreCase("valorizaciones")){%>
					<td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					<td width="50%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="4">Valorizaci&oacute;n</cellbytelabel></td>
					<td width="15%"><cellbytelabel id="4">Estado</cellbytelabel></td>
					<td width="10%"><cellbytelabel id="4">Acci&oacute;n</cellbytelabel></td>
				    <td width="10%">&nbsp;</td>
                    <%} else {%>
                      <td width="10%"><cellbytelabel id="1">C&oacute;digo</cellbytelabel></td>
					  <td width="60%"><cellbytelabel id="2">Descripci&oacute;n</cellbytelabel></td>
                      <td width="20%"><cellbytelabel id="1">Mostrar checkbox</cellbytelabel></td>
                      <td width="10%">&nbsp;</td>
                    <%}%>
			    </tr>			
				<%
				  if (HashDet.size() > 0) 
				  {  
				    String js = "";		
				    al = CmnMgr.reverseRecords(HashDet);
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString(); 
				   	  DetalleIntervenciones di = (DetalleIntervenciones) HashDet.get(key);
			    %>
				<tr class="TextRow01" align="center">
					<%=fb.hidden("key"+i,key)%> 
					<%=fb.hidden("remove"+i,"")%>
                    
                    <%if(fg.trim().equalsIgnoreCase("valorizaciones")){%>
					<td><%=fb.textBox("codigo"+i, di.getCodigoValorizacion(),false,false,true,5)%></td>
					<td><%=fb.textBox("descripcion"+i, di.getDescripcionValorizacion(),true,false,false,80,100)%></td>        
					<td>
                    <%if(!tipo.equalsIgnoreCase("SG")){%>
                        <%=fb.select("valorizacion"+i,"low=Bajo,medium=Medio,high=Alto,extreme=Extremado", di.getValorizacion(),false,false,0,"")%>
                    <%} else {%>
                        <%=fb.select("valorizacion"+i,"susan=Intervención", di.getValorizacion(),false,false,0,"")%>
                    <%}%>
                    </td> 
					<td><%=fb.select("estado"+i,"A=ACTIVO,I=INACTIVO",di.getEstadoValorizacion(),false,false,0,"")%></td>
                    <td>
                      <a href="javascript:setDetalles(<%=di.getCodigoValorizacion()%>,'<%=di.getDescripcionValorizacion()%>', '<%=di.getValorizacion()%>')" class="Link02Bold">Intervenciones</a>
                    </td>
				    <td><%=fb.submit("rem"+i,"X",false,(!di.getCodigoValorizacion().trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
                    <%} else {%>
                        <td><%=fb.textBox("codigo"+i, di.getCodigo(),false,false,true,5)%></td>
                        <td>
                            <%=fb.textBox("descripcion"+i, di.getDescripcion(),true,false,false,80,100)%>
                        </td>
                        <td>
                        <%=fb.checkbox("mostrar_checkbox"+i,"S",di.getMostrarCheckbox()!=null&&di.getMostrarCheckbox().equalsIgnoreCase("S"),false,null,null,"")%>
                        </td>
                        <td><%=fb.submit("rem"+i,"X",false,(!di.getCodigo().trim().equals("0")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
                    <%}%>
				</tr>
				<%	
				  }				  
					 fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar'){"+js+"}");	
					}
				%>
                
                <%if(fg.trim().equalsIgnoreCase("intervenciones")){%>
                    <tr class="TextRow02">
                        <td align="right" colspan="4">
                            <cellbytelabel id="4">Opciones de Guardar</cellbytelabel>:
                            <%=fb.radio("saveOption","N")%><cellbytelabel id="5">Crear Otro</cellbytelabel>
                            <%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel id="6">Mantener Abierto</cellbytelabel>
                            <%=fb.radio("saveOption","C")%><cellbytelabel id="7">Cerrar</cellbytelabel>
                            <%=fb.button("save","Guardar",true,false,null,null,"onClick='javascript:doSubmit(this.form.name, this.value)'")%>
                            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
                        </td>
                    </tr>
                <%}%>
            <%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
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
	  int keySize=Integer.parseInt(request.getParameter("keySize"));
	  mode = request.getParameter("mode");
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();
	  String ItemRemoved = "";
      String saveOption = request.getParameter("saveOption");
	  
	  for (int i=1; i<=keySize; i++){
       DetalleIntervenciones di = new DetalleIntervenciones();
       if (fg.trim().equalsIgnoreCase("valorizaciones")) {
         di.setCodigoValorizacion(request.getParameter("codigo"+i));
         di.setDescripcionValorizacion(request.getParameter("descripcion"+i));
         di.setEstadoValorizacion(request.getParameter("estado"+i));
         di.setValorizacion(request.getParameter("valorizacion"+i));
         di.setTipoValorizacion(tipo);
       } else if (fg.trim().equalsIgnoreCase("intervenciones")) {
         di.setCodigo(request.getParameter("codigo"+i));
         di.setDescripcion(request.getParameter("descripcion"+i));
         di.setCodigoIntervencion(request.getParameter("cod_interv_det"));
         if(request.getParameter("mostrar_checkbox"+i) != null ) di.setMostrarCheckbox("S");
         else di.setMostrarCheckbox("N");
         di.setTipo(tipo);
         
         System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::: cod_interv_det = "+request.getParameter("cod_interv_det"));
       }
		
	    key = request.getParameter("key"+i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){ 
		  ItemRemoved = key;
		}
		else{
	      try{ 
           HashDet.put(key, di);
           list.add(di);
		  }catch(Exception e){ System.err.println(e.getMessage()); }     
	    }
	  }

	  if (!ItemRemoved.equals("")){
	     HashDet.remove(ItemRemoved);
		 response.sendRedirect("../expediente/exp_intervencion_detalle.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&fg="+fg+"&cod_interv_det="+codIntervDet+"&change=1&cod_interv="+codInterv+"&desc_valorizacion="+descValorizacion+"&valorizacion="+valorizacion);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equalsIgnoreCase("Agregar")){
		DetalleIntervenciones di = new DetalleIntervenciones();
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		if(fg.trim().equalsIgnoreCase("intervenciones"))di.setCodigo("0");
		else di.setCodigoValorizacion("0");
		try{
		    HashDet.put(key, di);
            System.out.println("................................... HashDet.size() = "+HashDet.size());
		   }catch(Exception e){ System.err.println(e.getMessage()); }
		response.sendRedirect("../expediente/exp_intervencion_detalle.jsp?mode="+mode+"&lastLineNo="+lastLineNo+"&fg="+fg+"&cod_interv_det="+codIntervDet+"&change=1&cod_interv="+codInterv+"&desc_valorizacion="+descValorizacion+"&valorizacion="+valorizacion);
		return;
	  }
		Intervencion interv = new Intervencion();
		interv.setDescripcion(request.getParameter("intervencion"));
		if(fg.trim().equalsIgnoreCase("valorizaciones")) interv.setCodigo(request.getParameter("cod_interv"));
		else interv.setCodigo(request.getParameter("codigo"));
		interv.setEstado(request.getParameter("estado"));
		interv.setTipo(request.getParameter("tipo"));
        
		if (fg.trim().equalsIgnoreCase("intervenciones")) interv.setDetalles(list);
		else if (fg.trim().equalsIgnoreCase("valorizaciones")) interv.setValorizaciones(list);
		
		if (mode.equalsIgnoreCase("add")){
            IntervMgr.add(interv);
            codInterv = IntervMgr.getPkColValue("cod_interv");
		} 
		else if (mode.equalsIgnoreCase("edit")){
		   codInterv = interv.getCodigo();
		   IntervMgr.update(interv);
		}
%>
<html>
<head>
<script>
function closeWindow(){
  <%if (IntervMgr.getErrCode().equals("1")){%>
     <%if(fg.trim().equalsIgnoreCase("valorizaciones")){%>
	  parent.document.form1.errCode.value = '<%=IntervMgr.getErrCode()%>';
	  parent.document.form1.errMsg.value = '<%=IntervMgr.getErrMsg()%>';
	  parent.document.form1.cod_interv.value = '<%=codInterv%>';
	  parent.document.form1.cod_interv_det.value = '<%=codIntervDet%>';
	  parent.document.form1.submit();
      <%} else {%>
      
        alert('<%=IntervMgr.getErrMsg()%>');
        
        <%if (saveOption.equalsIgnoreCase("N")){%>
           setTimeout('addMode()',500);
        <%} else if (saveOption.equalsIgnoreCase("O")) {%>
           setTimeout('editMode()',500);
        <%} else if (saveOption.equalsIgnoreCase("C")) {%>
          parent.hidePopWin(false);
        <%}%>
      
      <%}%>
  <%} else throw new Exception(IntervMgr.getErrMsg());%>

}

<%if(fg.trim().equalsIgnoreCase("intervenciones")){%>
function addMode(){
    window.location ='../expediente/exp_intervencion_detalle.jsp?fg=intervenciones&mode=<%=mode%>&cod_interv_det=<%=codIntervDet%>&tipo=<%=tipo%>&desc_valorizacion=<%=descValorizacion%>&valorizacion=<%=valorizacion%>'
}
function editMode(){
    window.location ='../expediente/exp_intervencion_detalle.jsp?fg=intervenciones&mode=<%=mode%>&cod_interv_det=<%=codIntervDet%>&tipo=<%=tipo%>&desc_valorizacion=<%=descValorizacion%>&valorizacion=<%=valorizacion%>'
}
<%}%>
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>