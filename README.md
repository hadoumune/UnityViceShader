# UnityViceShader
VJ Shader for Unity(Unity2018.4.21f1)

# Setup Light Settings
Change the Skybox material in Lighting Preferences to ViceSkybox 

# Edit Shader
Implement the code for the "vice" function in ViceShader.shader

## simple oscillator
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return osc(st);
}
```

## simple shape
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return shape(st);
}
```
## combination operator
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return mult(osc(rotate(st, 0.5, 0),100,0.05,0),shape(repeat(st, 20, 16, 0, 0),12,0.1,0),1);
}
```
![combination](https://raw.github.com/wiki/hadoumune/UnityViceShader/images/ViceSample03.png)
