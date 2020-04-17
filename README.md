# UnityViceShader
VJ Shader for Unity(Unity2018.4.21f1)
Vice has a function similar to Hydra

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
![combination](https://raw.github.com/wiki/hadoumune/UnityViceShader/images/ViceSample01.png)

## simple shape
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return shape(st);
}
```
![combination](https://raw.github.com/wiki/hadoumune/UnityViceShader/images/ViceSample02.png)

## simple kaleidscope
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return osc(kaleid(st));
}
```
![combination](https://raw.github.com/wiki/hadoumune/UnityViceShader/images/ViceSample04.png)

## simple edge(Vice original)
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return edge(repeat(st));
}
```
![combination](https://raw.github.com/wiki/hadoumune/UnityViceShader/images/ViceSample05.png)


## combination operator
```
float4 vice(float3 cameraPos, float3 rayDir, float4 screenPos,float2 st)
{
  return mult(osc(rotate(st, 0.5, 0),100,0.05,0),shape(repeat(st, 20, 16, 0, 0),12,0.1,0),1);
}
```
![combination](https://raw.github.com/wiki/hadoumune/UnityViceShader/images/ViceSample03.png)
