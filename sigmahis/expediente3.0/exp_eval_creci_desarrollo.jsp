<%if(alC.size() > 0) {
    String tituloEdad = "";
    if (fg.trim().equalsIgnoreCase("PE")) {
        if (edadMes > 0 && edadMes <= 36 && edad < 4) tituloEdad = edadMes+" meses";
        else if (edad >=4 && edad <= 11) tituloEdad = edad+" años";
    } else {
      if (edad <= 19) tituloEdad = edad+" años";
    }
    %>

    <tr class="bg-headtabla2">
        <th colspan="4">EVALUACIÓN DE CRECIMIENTO Y DESARROLLO&nbsp;&nbsp;&nbsp;&nbsp;(<%=tituloEdad%>)</th>
    </tr>
    <%
    String grupo = "";
    for (int i = 0; i<alC.size(); i++){
    CommonDataObject cdoC = (CommonDataObject) alC.get(i);

    if (!grupo.equals(cdoC.getColValue("grupo"))){
    %>
      <tr class="bg-headtabla">
         <td colspan="4"><%=cdoC.getColValue("grupo")%></td>
      </tr>
    <%
    }
    %>
          
          
          <tr>
            <td colspan="4">
              <label class="pointer"><%=fb.checkbox("evaluacion_crecimiento"+i,""+i,prop.getProperty("evaluacion_crecimiento"+i)!=null&&prop.getProperty("evaluacion_crecimiento"+i).equals(""+i),viewMode,null,null,"","")%>&nbsp;&nbsp;<%=cdoC.getColValue("descripcion")%></label>
            </td>
          </tr>
          <%if( (i+1) == alC.size()) {%>
            <tr>
                <td colspan="4"><b>Observaciones</b>&nbsp;&nbsp;
                  <%=fb.textarea("observacion1",prop.getProperty("observacion1"),false,false,viewMode,0,0,2000,"form-control input-sm","",null)%>
                </td>
            </tr>
          <%}%>
    <%
    grupo = cdoC.getColValue("grupo");
    }%>        
<%}%>