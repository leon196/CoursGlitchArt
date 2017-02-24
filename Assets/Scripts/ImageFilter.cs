using UnityEngine;
using System.Collections;

public class ImageFilter : MonoBehaviour 
{
	public Shader shader;
	private Material material;
	
	void Start ()
	{
		material = new Material(shader);
	}

	void OnRenderImage (RenderTexture source, RenderTexture destination) 
	{
		Graphics.Blit (source, destination, material);
	}
}